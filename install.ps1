[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Source,

    [switch]$Offline
)

$ErrorActionPreference = "Stop"
$PluginName = "open-study"
$MarketplaceName = "open-study"
$GitRef = "plugin-stable"
# 要和 backend/bilistudy/cloud.py 的 _MINIMUM_PLUGIN_VERSION 保持一致。
$MinimumVersion = [Version]"0.6.0"
$PackageRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
$script:CreatedMarketplaceName = ""

function Stop-Install {
    param([string]$Message)
    throw "Open Study installation failed: $Message"
}

function Get-CanonicalGitSource {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value) -or $Value -match '\s') {
        Stop-Install "the GitHub source cannot be empty or contain whitespace."
    }
    $Repository = $Value.TrimEnd('/')
    if ($Repository -match '^https://github\.com/([^/]+)/([^/]+)$') {
        $Owner = $Matches[1]
        $Repo = $Matches[2]
    } elseif ($Repository -match '^([^/:]+)/([^/]+)$') {
        $Owner = $Matches[1]
        $Repo = $Matches[2]
    } else {
        Stop-Install "use OWNER/REPO or an HTTPS github.com repository URL."
    }
    if ($Repo.EndsWith('.git', [System.StringComparison]::OrdinalIgnoreCase)) {
        $Repo = $Repo.Substring(0, $Repo.Length - 4)
    }
    if ($Owner -notmatch '^[A-Za-z0-9_.-]+$' -or $Repo -notmatch '^[A-Za-z0-9_.-]+$') {
        Stop-Install "the GitHub owner or repository name is invalid."
    }
    return "$Owner/$Repo".ToLowerInvariant()
}

function Get-MarketplaceRef {
    param($Record, [string]$ConfiguredSource)
    foreach ($Container in @($Record.marketplaceSource, $Record)) {
        foreach ($Property in @("refName", "ref", "gitRef")) {
            $Candidate = [string]$Container.$Property
            if (-not [string]::IsNullOrWhiteSpace($Candidate)) { return $Candidate }
        }
    }
    if ([string]$Record.marketplaceSource.sourceType -notin @("git", "github") -or [string]::IsNullOrWhiteSpace([string]$Record.root)) { return "" }
    $SnapshotRoot = [string]$Record.root
    $Bookkeeping = Join-Path $SnapshotRoot ".codex-marketplace-install.json"
    $Expected = Get-CanonicalGitSource $ConfiguredSource
    if (Test-Path -LiteralPath $Bookkeeping -PathType Leaf) {
        try { $Snapshot = Get-Content -LiteralPath $Bookkeeping -Raw | ConvertFrom-Json } catch { return "" }
        if ($Snapshot.source_type -in @("git", "github") -and -not [string]::IsNullOrWhiteSpace([string]$Snapshot.source)) {
            if ((Get-CanonicalGitSource ([string]$Snapshot.source)) -eq $Expected) { return [string]$Snapshot.ref_name }
        }
    } elseif ((Test-Path -LiteralPath (Join-Path $SnapshotRoot ".git")) -and (Get-Command git -ErrorAction SilentlyContinue)) {
        $Origin = (& git -C $SnapshotRoot config --local --get remote.origin.url 2>$null | Out-String).Trim()
        if ($LASTEXITCODE -ne 0) { return "" }
        $Branch = (& git -C $SnapshotRoot symbolic-ref --quiet --short HEAD 2>$null | Out-String).Trim()
        if ($LASTEXITCODE -eq 0 -and (Get-CanonicalGitSource $Origin) -eq $Expected) { return $Branch }
    }
    return ""
}

function Invoke-CodexJson {
    param(
        [string[]]$Arguments,
        [string]$FailureMessage
    )
    $Output = (& codex @Arguments | Out-String)
    if ($LASTEXITCODE -ne 0) {
        Stop-Install $FailureMessage
    }
    return $Output
}

function Get-MarketplaceState {
    $PayloadText = Invoke-CodexJson -Arguments @("plugin", "marketplace", "list", "--json") -FailureMessage "Codex could not list plugin marketplaces."
    try {
        $Payload = $PayloadText | ConvertFrom-Json
    } catch {
        Stop-Install "Codex returned invalid marketplace information."
    }

    $MatchesFound = @($Payload.marketplaces | Where-Object { $_.name -eq $MarketplaceName })
    if ($MatchesFound.Count -eq 0) {
        return [PSCustomObject]@{ Kind = "missing"; Source = ""; Ref = "" }
    }
    if ($MatchesFound.Count -ne 1) {
        return [PSCustomObject]@{ Kind = "duplicate"; Source = ""; Ref = "" }
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
    $ConfiguredRef = Get-MarketplaceRef $Record $ConfiguredSource

    if ($SourceType -eq "local") {
        if ([string]::IsNullOrWhiteSpace($ConfiguredSource)) {
            $ConfiguredSource = [string]$Record.root
        }
        return [PSCustomObject]@{ Kind = "local"; Source = $ConfiguredSource; Ref = "" }
    }
    if ($SourceType -in @("git", "github")) {
        return [PSCustomObject]@{ Kind = "git"; Source = $ConfiguredSource; Ref = $ConfiguredRef }
    }
    return [PSCustomObject]@{ Kind = "unknown"; Source = $ConfiguredSource; Ref = $ConfiguredRef }
}

function Undo-NewMarketplace {
    if ([string]::IsNullOrWhiteSpace($script:CreatedMarketplaceName)) {
        return
    }
    try {
        & codex plugin marketplace remove $script:CreatedMarketplaceName --json *> $null
        $Removed = $LASTEXITCODE -eq 0
    } catch {
        $Removed = $false
    }
    if ($Removed) {
        Write-Warning "The newly added $($script:CreatedMarketplaceName) marketplace was rolled back."
        $script:CreatedMarketplaceName = ""
    } else {
        Write-Warning "Codex could not roll back the newly added $($script:CreatedMarketplaceName) marketplace. Inspect 'codex plugin marketplace list --json' before removing only that marketplace."
    }
}

function Stop-InstallWithRollback {
    param([string]$Message)
    Undo-NewMarketplace
    Stop-Install $Message
}

function Add-MarketplaceSafely {
    param([string[]]$Arguments)

    $PayloadText = Invoke-CodexJson -Arguments (@("plugin", "marketplace", "add") + $Arguments + @("--json")) -FailureMessage "Codex could not add the marketplace."
    try {
        $Payload = $PayloadText | ConvertFrom-Json
    } catch {
        Stop-Install "Codex added a marketplace but returned an invalid result. Inspect 'codex plugin marketplace list --json' before retrying."
    }
    $AddedName = [string]$Payload.marketplaceName
    if ($AddedName -notmatch '^[a-z0-9](?:[a-z0-9-]{0,62}[a-z0-9])?$' -or $Payload.alreadyAdded -isnot [bool]) {
        Stop-Install "Codex added a marketplace but returned an incomplete result. Inspect 'codex plugin marketplace list --json' before retrying."
    }
    $WasAlreadyAdded = [bool]$Payload.alreadyAdded
    if ($AddedName -ne $MarketplaceName) {
        if (-not $WasAlreadyAdded) {
            $script:CreatedMarketplaceName = $AddedName
            Undo-NewMarketplace
        }
        Stop-Install "the selected source advertises marketplace '$AddedName', not '$MarketplaceName'; it was not used."
    }
    if (-not $WasAlreadyAdded) {
        $script:CreatedMarketplaceName = $AddedName
    }
}

function Confirm-PluginInstall {
    param(
        [string]$PayloadText,
        [string]$ExpectedVersion
    )

    try {
        $Payload = $PayloadText | ConvertFrom-Json
    } catch {
        Stop-InstallWithRollback "Codex reported success but returned invalid plugin information."
    }
    if ($Payload.pluginId -ne "open-study@open-study" -or $Payload.name -ne $PluginName -or $Payload.marketplaceName -ne $MarketplaceName) {
        Stop-InstallWithRollback "Codex reported success but the installed plugin identity could not be verified."
    }
    $VersionText = [string]$Payload.version
    $VersionMatch = [regex]::Match($VersionText, '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$')
    if (-not $VersionMatch.Success) {
        Stop-InstallWithRollback "Codex reported an invalid plugin version."
    }
    if (-not [string]::IsNullOrWhiteSpace($ExpectedVersion) -and $VersionText -ne $ExpectedVersion) {
        Stop-InstallWithRollback "the offline package installed $VersionText instead of $ExpectedVersion."
    }
    $CoreVersion = [Version]("{0}.{1}.{2}" -f $VersionMatch.Groups[1].Value, $VersionMatch.Groups[2].Value, $VersionMatch.Groups[3].Value)
    if ($CoreVersion -lt $MinimumVersion) {
        Stop-InstallWithRollback "plugin $VersionText is older than supported $MinimumVersion."
    }
    return $VersionText
}

if ($Offline -and -not [string]::IsNullOrWhiteSpace($Source)) {
    Stop-Install "-Offline cannot be combined with a GitHub source."
}
if (-not $Offline -and [string]::IsNullOrWhiteSpace($Source)) {
    Stop-Install "provide a published OWNER/REPO or HTTPS GitHub URL, or use -Offline with an extracted ZIP."
}
if (-not $Offline) {
    $RequestedSource = Get-CanonicalGitSource $Source
}
if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    Stop-Install "the Codex CLI is not available in PATH."
}

$Marketplace = Get-MarketplaceState
$ExpectedVersion = ""
if ($Offline) {
    $MarketplaceFile = Join-Path $PackageRoot ".agents/plugins/marketplace.json"
    $PluginFile = Join-Path $PackageRoot "plugins/open-study/.codex-plugin/plugin.json"
    if (-not (Test-Path -LiteralPath $MarketplaceFile -PathType Leaf)) {
        Stop-Install "marketplace.json is missing. Extract the complete ZIP before installing."
    }
    if (-not (Test-Path -LiteralPath $PluginFile -PathType Leaf)) {
        Stop-Install "the Open Study plugin source is missing."
    }
    try {
        $Manifest = Get-Content -LiteralPath $PluginFile -Raw | ConvertFrom-Json
    } catch {
        Stop-Install "the extracted plugin manifest is invalid."
    }
    # 以前这里硬编码等于 0.6.0，任何新版离线包都会被拒；改成和 .sh 一样只要求
    # 不低于 $MinimumVersion。
    $ManifestVersionText = [string]$Manifest.version
    $ManifestMatch = [regex]::Match($ManifestVersionText, '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$')
    if ($Manifest.name -ne $PluginName -or -not $ManifestMatch.Success) {
        Stop-Install "the extracted ZIP is not an approved Open Study package (need v$MinimumVersion or newer)."
    }
    $ManifestCoreVersion = [Version]("{0}.{1}.{2}" -f $ManifestMatch.Groups[1].Value, $ManifestMatch.Groups[2].Value, $ManifestMatch.Groups[3].Value)
    if ($ManifestCoreVersion -lt $MinimumVersion) {
        Stop-Install "the extracted ZIP is not an approved Open Study package (need v$MinimumVersion or newer)."
    }
    $ExpectedVersion = [string]$Manifest.version

    switch ($Marketplace.Kind) {
        "missing" {
            Add-MarketplaceSafely -Arguments @($PackageRoot)
            try { $Marketplace = Get-MarketplaceState } catch { Undo-NewMarketplace; throw }
        }
        "local" { }
        "git" { Stop-Install "the $MarketplaceName marketplace already follows GitHub. It was left unchanged; use the update script instead." }
        "duplicate" { Stop-Install "more than one marketplace named $MarketplaceName is configured. Resolve the duplicate before retrying." }
        default { Stop-Install "the existing $MarketplaceName marketplace source could not be verified, so it was left unchanged." }
    }
    if ($Marketplace.Kind -ne "local") {
        Stop-InstallWithRollback "the newly added source did not register the expected local marketplace."
    }
    $ExistingRoot = [System.IO.Path]::GetFullPath([string]$Marketplace.Source)
    if (-not [string]::Equals($ExistingRoot.TrimEnd('\', '/'), $PackageRoot.TrimEnd('\', '/'), [System.StringComparison]::OrdinalIgnoreCase)) {
        Stop-InstallWithRollback "a different local marketplace named $MarketplaceName is configured. It was left unchanged."
    }
    $InstalledFrom = "the offline ZIP"
} else {
    switch ($Marketplace.Kind) {
        "missing" {
            Add-MarketplaceSafely -Arguments @($Source, "--ref", $GitRef)
            try { $Marketplace = Get-MarketplaceState } catch { Undo-NewMarketplace; throw }
        }
        "local" { Stop-Install "a local ZIP marketplace named $MarketplaceName is already configured. It was left unchanged; follow the documented migration before switching to GitHub." }
        "git" { }
        "duplicate" { Stop-Install "more than one marketplace named $MarketplaceName is configured. Resolve the duplicate before retrying." }
        default { Stop-Install "the existing $MarketplaceName marketplace source could not be verified, so it was left unchanged." }
    }
    if ($Marketplace.Kind -ne "git" -or [string]::IsNullOrWhiteSpace([string]$Marketplace.Source)) {
        Stop-InstallWithRollback "the selected repository did not register the expected Git marketplace."
    }
    try { $ConfiguredSource = Get-CanonicalGitSource ([string]$Marketplace.Source) } catch { Undo-NewMarketplace; throw }
    if ($ConfiguredSource -ne $RequestedSource) {
        Stop-InstallWithRollback "the $MarketplaceName marketplace points to a different GitHub repository. It was left unchanged."
    }
    if ([string]$Marketplace.Ref -ne $GitRef) {
        Stop-InstallWithRollback "the $MarketplaceName marketplace is not pinned to the verified $GitRef ref. It was left unchanged."
    }
    if ([string]::IsNullOrWhiteSpace($script:CreatedMarketplaceName)) {
        [void](Invoke-CodexJson -Arguments @("plugin", "marketplace", "upgrade", $MarketplaceName, "--json") -FailureMessage "Codex could not refresh the GitHub marketplace. The installed plugin was left unchanged.")
    }
    $InstalledFrom = $ConfiguredSource
}

try {
    $InstallResult = Invoke-CodexJson -Arguments @("plugin", "add", "$PluginName@$MarketplaceName", "--json") -FailureMessage "Codex could not install the Open Study plugin. Any previous installation was left unchanged."
    $InstalledVersion = Confirm-PluginInstall -PayloadText $InstallResult -ExpectedVersion $ExpectedVersion
} catch {
    Undo-NewMarketplace
    throw
}
$script:CreatedMarketplaceName = ""
Write-Host "Open Study $InstalledVersion is installed from $InstalledFrom. Start a new Codex task to load the updated Skill and MCP connection."
