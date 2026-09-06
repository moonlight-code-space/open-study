[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Source
)

$ErrorActionPreference = "Stop"
$PluginName = "open-study"
$MarketplaceName = "open-study"
$GitRef = "plugin-stable"
$MinimumVersion = [Version]"0.6.0"

function Stop-Update {
    param([string]$Message)
    throw "Open Study update failed: $Message"
}

function Get-CanonicalGitSource {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value) -or $Value -match '\s') {
        Stop-Update "the GitHub source cannot be empty or contain whitespace."
    }
    $Repository = $Value.TrimEnd('/')
    if ($Repository -match '^https://github\.com/([^/]+)/([^/]+)$') {
        $Owner = $Matches[1]
        $Repo = $Matches[2]
    } elseif ($Repository -match '^([^/:]+)/([^/]+)$') {
        $Owner = $Matches[1]
        $Repo = $Matches[2]
    } else {
        Stop-Update "use OWNER/REPO or an HTTPS github.com repository URL."
    }
    if ($Repo.EndsWith('.git', [System.StringComparison]::OrdinalIgnoreCase)) {
        $Repo = $Repo.Substring(0, $Repo.Length - 4)
    }
    if ($Owner -notmatch '^[A-Za-z0-9_.-]+$' -or $Repo -notmatch '^[A-Za-z0-9_.-]+$') {
        Stop-Update "the GitHub owner or repository name is invalid."
    }
    return "$Owner/$Repo".ToLowerInvariant()
}

function Invoke-CodexJson {
    param(
        [string[]]$Arguments,
        [string]$FailureMessage
    )
    $Output = (& codex @Arguments | Out-String)
    if ($LASTEXITCODE -ne 0) {
        Stop-Update $FailureMessage
    }
    return $Output
}

function Confirm-PluginInstall {
    param([string]$PayloadText)
    try {
        $Payload = $PayloadText | ConvertFrom-Json
    } catch {
        Stop-Update "Codex reported success but returned invalid plugin information."
    }
    if ($Payload.pluginId -ne "open-study@open-study" -or $Payload.name -ne $PluginName -or $Payload.marketplaceName -ne $MarketplaceName) {
        Stop-Update "Codex reported success but the installed plugin identity could not be verified."
    }
    $VersionText = [string]$Payload.version
    $VersionMatch = [regex]::Match($VersionText, '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$')
    if (-not $VersionMatch.Success) {
        Stop-Update "Codex reported an invalid plugin version."
    }
    $CoreVersion = [Version]("{0}.{1}.{2}" -f $VersionMatch.Groups[1].Value, $VersionMatch.Groups[2].Value, $VersionMatch.Groups[3].Value)
    if ($CoreVersion -lt $MinimumVersion) {
        Stop-Update "plugin $VersionText is older than supported $MinimumVersion."
    }
    return $VersionText
}

if (-not [string]::IsNullOrWhiteSpace($Source)) {
    $RequestedSource = Get-CanonicalGitSource $Source
} else {
    $RequestedSource = ""
}
if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    Stop-Update "the Codex CLI is not available in PATH."
}
$PayloadText = Invoke-CodexJson -Arguments @("plugin", "marketplace", "list", "--json") -FailureMessage "Codex could not list plugin marketplaces."
try {
    $Payload = $PayloadText | ConvertFrom-Json
} catch {
    Stop-Update "Codex returned invalid marketplace information."
}

$MatchesFound = @($Payload.marketplaces | Where-Object { $_.name -eq $MarketplaceName })
if ($MatchesFound.Count -eq 0) {
    Stop-Update "the $MarketplaceName marketplace is not installed. Run the installer first."
}
if ($MatchesFound.Count -ne 1) {
    Stop-Update "more than one marketplace named $MarketplaceName is configured. Resolve the duplicate before retrying."
}

$Record = $MatchesFound[0]
$SourceType = [string]$Record.marketplaceSource.sourceType
$ConfiguredSource = ""
foreach ($Property in @("source", "url", "repository", "repo")) {
    $Candidate = [string]$Record.marketplaceSource.$Property
    if (-not [string]::IsNullOrWhiteSpace($Candidate)) {
        $ConfiguredSource = $Candidate
        break
    }
}
$ConfiguredRef = ""
foreach ($Container in @($Record.marketplaceSource, $Record)) {
    foreach ($Property in @("refName", "ref", "gitRef")) {
        $Candidate = [string]$Container.$Property
        if (-not [string]::IsNullOrWhiteSpace($Candidate)) {
            $ConfiguredRef = $Candidate
            break
        }
    }
    if (-not [string]::IsNullOrWhiteSpace($ConfiguredRef)) {
        break
    }
}
if ($SourceType -eq "local") {
    Stop-Update "the $MarketplaceName marketplace was installed from a ZIP. It was left unchanged; follow the documented migration before using Git updates."
}
if ($SourceType -notin @("git", "github") -or [string]::IsNullOrWhiteSpace($ConfiguredSource)) {
    Stop-Update "the existing $MarketplaceName marketplace source could not be verified, so it was left unchanged."
}
$ConfiguredCanonical = Get-CanonicalGitSource $ConfiguredSource
if (-not [string]::IsNullOrWhiteSpace($RequestedSource) -and $ConfiguredCanonical -ne $RequestedSource) {
    Stop-Update "the $MarketplaceName marketplace points to a different GitHub repository. It was left unchanged."
}
if ($ConfiguredRef -ne $GitRef) {
    Stop-Update "the $MarketplaceName marketplace is not pinned to the verified $GitRef ref. It was left unchanged."
}

[void](Invoke-CodexJson -Arguments @("plugin", "marketplace", "upgrade", $MarketplaceName, "--json") -FailureMessage "Codex could not refresh the GitHub marketplace. The installed plugin was left unchanged.")
$InstallResult = Invoke-CodexJson -Arguments @("plugin", "add", "$PluginName@$MarketplaceName", "--json") -FailureMessage "Codex refreshed the marketplace but could not install the update. The previously installed plugin remains; rerun the update after resolving the error."
$InstalledVersion = Confirm-PluginInstall -PayloadText $InstallResult
Write-Host "Open Study is updated to $InstalledVersion from $ConfiguredCanonical. Start a new Codex task to load the updated Skill and MCP connection."
