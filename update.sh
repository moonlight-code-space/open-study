#!/bin/sh
set -eu

PLUGIN_NAME="open-study"
MARKETPLACE_NAME="open-study"
GIT_REF="plugin-stable"
MINIMUM_VERSION="0.6.0"
SOURCE=""

usage() {
  cat <<'EOF'
Update the Open Study Codex plugin from its configured GitHub marketplace.

Usage:
  sh Update-OpenStudy-Plugin.sh
  sh Update-OpenStudy-Plugin.sh moonlight-code-space/open-study
  sh Update-OpenStudy-Plugin.sh https://github.com/moonlight-code-space/open-study

The optional repository is only a source check. The configured marketplace
must already point to the verified plugin-stable ref.

Options:
  --source SOURCE       Optional expected GitHub OWNER/REPO or HTTPS URL
  -h, --help            Show this help
EOF
}

fail() {
  printf '%s\n' "Open Study update failed: $*" >&2
  exit 1
}

canonical_git_source() {
  value=$1
  case "$value" in *[[:space:]]*) fail "the GitHub source cannot contain whitespace." ;; esac
  case "$value" in
    https://github.com/*) repository=${value#https://github.com/} ;;
    http://* | https://* | ssh://* | git@* | file://*) fail "use OWNER/REPO or an HTTPS github.com repository URL." ;;
    *) repository=$value ;;
  esac
  repository=${repository%/}
  repository=${repository%.git}
  owner=${repository%%/*}
  repo=${repository#*/}
  test "$repo" != "$repository" || fail "use a GitHub repository in OWNER/REPO form."
  case "$repo" in */*) fail "the GitHub source must contain exactly OWNER/REPO." ;; esac
  case "$owner" in "" | *[!A-Za-z0-9_.-]*) fail "the GitHub owner is invalid." ;; esac
  case "$repo" in "" | *[!A-Za-z0-9_.-]*) fail "the GitHub repository name is invalid." ;; esac
  printf '%s/%s\n' "$owner" "$repo" | tr '[:upper:]' '[:lower:]'
}

inspect_marketplace() {
  printf '%s' "$1" | python3 -c '
import json
import sys

name = sys.argv[1]
try:
    payload = json.load(sys.stdin)
except (TypeError, ValueError) as exc:
    raise SystemExit(f"invalid marketplace JSON: {exc}")
items = payload.get("marketplaces", [])
if not isinstance(items, list):
    raise SystemExit("invalid marketplace list")
matches = [item for item in items if isinstance(item, dict) and item.get("name") == name]
if not matches:
    print("missing")
    print()
    print()
    raise SystemExit(0)
if len(matches) != 1:
    print("duplicate")
    print()
    print()
    raise SystemExit(0)
item = matches[0]
metadata = item.get("marketplaceSource")
metadata = metadata if isinstance(metadata, dict) else {}
source_type = str(metadata.get("sourceType", "")).lower()
source = next(
    (str(metadata[key]) for key in ("source", "url", "repository", "repo") if metadata.get(key)),
    "",
)
ref_name = next(
    (
        str(container[key])
        for container in (metadata, item)
        for key in ("refName", "ref", "gitRef")
        if container.get(key)
    ),
    "",
)
if source_type == "local":
    print("local")
    print(source or str(item.get("root", "")))
    print()
elif source_type in {"git", "github"}:
    print("git")
    print(source)
    print(ref_name)
else:
    print("unknown")
    print(source or str(item.get("root", "")))
    print(ref_name)
' "$MARKETPLACE_NAME"
}

verify_install_result() {
  printf '%s' "$1" | python3 -c '
import json
import re
import sys

minimum_version = sys.argv[1]
try:
    payload = json.load(sys.stdin)
except (TypeError, ValueError) as exc:
    raise SystemExit(f"invalid plugin install JSON: {exc}")
if payload.get("pluginId") != "open-study@open-study":
    raise SystemExit("unexpected plugin id")
if payload.get("name") != "open-study" or payload.get("marketplaceName") != "open-study":
    raise SystemExit("unexpected plugin identity")
version = payload.get("version")
match = re.fullmatch(
    r"(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)"
    r"(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?",
    version if isinstance(version, str) else "",
)
if match is None:
    raise SystemExit("invalid plugin version")
minimum = tuple(int(part) for part in minimum_version.split("."))
current = tuple(int(part) for part in match.groups())
if current < minimum:
    raise SystemExit(f"plugin {version} is older than supported {minimum_version}")
print(version)
' "$MINIMUM_VERSION" || fail "Codex reported success but the installed plugin identity or version could not be verified."
}

while test "$#" -gt 0; do
  case "$1" in
    --source)
      test "$#" -ge 2 || fail "--source requires OWNER/REPO or an HTTPS GitHub URL."
      test -z "$SOURCE" || fail "only one GitHub source may be provided."
      SOURCE=$2
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --*) fail "unknown option: $1" ;;
    *)
      test -z "$SOURCE" || fail "only one GitHub source may be provided."
      SOURCE=$1
      shift
      ;;
  esac
done

if test -n "$SOURCE"; then
  requested_source=$(canonical_git_source "$SOURCE")
else
  requested_source=""
fi

command -v codex >/dev/null 2>&1 || fail "the Codex CLI is not available in PATH."
command -v python3 >/dev/null 2>&1 || fail "Python 3 is required to verify Codex results safely."
marketplace_json=$(codex plugin marketplace list --json) || fail "Codex could not list plugin marketplaces."
marketplace_details=$(inspect_marketplace "$marketplace_json") || fail "Codex returned invalid marketplace information."
marketplace_kind=$(printf '%s\n' "$marketplace_details" | sed -n '1p')
configured_source=$(printf '%s\n' "$marketplace_details" | sed -n '2p')
configured_ref=$(printf '%s\n' "$marketplace_details" | sed -n '3p')

case "$marketplace_kind" in
  missing)
    fail "the $MARKETPLACE_NAME marketplace is not installed. Run the installer first."
    ;;
  local)
    fail "the $MARKETPLACE_NAME marketplace was installed from a ZIP. It was left unchanged; follow the documented migration before using Git updates."
    ;;
  git)
    test -n "$configured_source" || fail "the configured Git marketplace did not report its source. It was left unchanged."
    configured_canonical=$(canonical_git_source "$configured_source")
    if test -n "$requested_source"; then
      test "$configured_canonical" = "$requested_source" || fail "the $MARKETPLACE_NAME marketplace points to a different GitHub repository. It was left unchanged."
    fi
    test "$configured_ref" = "$GIT_REF" || fail "the $MARKETPLACE_NAME marketplace is not pinned to the verified $GIT_REF ref. It was left unchanged."
    ;;
  duplicate)
    fail "more than one marketplace named $MARKETPLACE_NAME is configured. Resolve the duplicate before retrying."
    ;;
  *)
    fail "the existing $MARKETPLACE_NAME marketplace source could not be verified, so it was left unchanged."
    ;;
esac

codex plugin marketplace upgrade "$MARKETPLACE_NAME" --json >/dev/null || fail "Codex could not refresh the GitHub marketplace. The installed plugin was left unchanged."
if ! install_json=$(codex plugin add "$PLUGIN_NAME@$MARKETPLACE_NAME" --json); then
  fail "Codex refreshed the marketplace but could not install the update. The previously installed plugin remains; rerun the update after resolving the error."
fi
installed_version=$(verify_install_result "$install_json")

printf '%s\n' "Open Study is updated to $installed_version from $configured_canonical. Start a new Codex task to load the updated Skill and MCP connection."
