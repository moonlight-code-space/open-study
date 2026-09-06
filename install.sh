#!/bin/sh
set -eu

PLUGIN_NAME="open-study"
MARKETPLACE_NAME="open-study"
GIT_REF="plugin-stable"
# 包里 plugin.json 说自己是哪一版就是哪一版；这里只要求它别倒退。
# 要和 backend/bilistudy/cloud.py 的 _MINIMUM_PLUGIN_VERSION 保持一致。
MINIMUM_VERSION="0.6.0"
PACKAGE_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
SOURCE=""
OFFLINE=0
ADDED_MARKETPLACE=""

usage() {
  cat <<'EOF'
Install the Open Study Codex plugin.

GitHub stable channel:
  sh Install-OpenStudy-Plugin.sh moonlight-code-space/open-study
  sh Install-OpenStudy-Plugin.sh https://github.com/moonlight-code-space/open-study

Extracted ZIP (offline fallback):
  sh install.sh --offline

Options:
  --source SOURCE       GitHub OWNER/REPO or HTTPS repository URL
  --offline             Install from this extracted ZIP
  -h, --help            Show this help
EOF
}

fail() {
  printf '%s\n' "Open Study installation failed: $*" >&2
  exit 1
}

canonical_git_source() {
  value=$1
  case "$value" in
    *[[:space:]]*) fail "the GitHub source cannot contain whitespace." ;;
  esac

  case "$value" in
    https://github.com/*)
      repository=${value#https://github.com/}
      ;;
    http://* | https://* | ssh://* | git@* | file://*)
      fail "use OWNER/REPO or an HTTPS github.com repository URL."
      ;;
    *)
      repository=$value
      ;;
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

parse_marketplace_add() {
  printf '%s' "$1" | python3 -c '
import json
import re
import sys

try:
    payload = json.load(sys.stdin)
except (TypeError, ValueError) as exc:
    raise SystemExit(f"invalid marketplace add JSON: {exc}")
name = payload.get("marketplaceName")
already_added = payload.get("alreadyAdded")
if not isinstance(name, str) or not re.fullmatch(r"[a-z0-9](?:[a-z0-9-]{0,62}[a-z0-9])?", name):
    raise SystemExit("invalid marketplace name in add result")
if not isinstance(already_added, bool):
    raise SystemExit("missing alreadyAdded flag in add result")
print(name)
print("existing" if already_added else "created")
'
}

rollback_added_marketplace() {
  test -n "$ADDED_MARKETPLACE" || return 0
  if codex plugin marketplace remove "$ADDED_MARKETPLACE" --json >/dev/null 2>&1; then
    printf '%s\n' "The newly added $ADDED_MARKETPLACE marketplace was rolled back." >&2
    ADDED_MARKETPLACE=""
    return 0
  fi
  printf '%s\n' "Warning: Codex could not roll back the newly added $ADDED_MARKETPLACE marketplace; inspect 'codex plugin marketplace list --json' before removing only that marketplace." >&2
  return 1
}

fail_with_rollback() {
  message=$1
  rollback_added_marketplace || true
  fail "$message"
}

add_marketplace() {
  if ! add_json=$(codex plugin marketplace add "$@" --json); then
    fail "Codex could not add the marketplace."
  fi
  if ! add_details=$(parse_marketplace_add "$add_json"); then
    fail "Codex may have added a marketplace but returned an invalid result. Inspect 'codex plugin marketplace list --json' before retrying."
  fi
  added_name=$(printf '%s\n' "$add_details" | sed -n '1p')
  added_state=$(printf '%s\n' "$add_details" | sed -n '2p')

  if test "$added_name" != "$MARKETPLACE_NAME"; then
    if test "$added_state" = "created"; then
      ADDED_MARKETPLACE=$added_name
      rollback_added_marketplace || true
    fi
    fail "the selected source advertises marketplace '$added_name', not '$MARKETPLACE_NAME'; it was not used."
  fi
  if test "$added_state" = "created"; then
    ADDED_MARKETPLACE=$added_name
  fi
}

verify_install_result() {
  printf '%s' "$1" | python3 -c '
import json
import re
import sys

expected_version, minimum_version = sys.argv[1:]
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
if expected_version and version != expected_version:
    raise SystemExit(f"expected plugin {expected_version}, got {version}")
minimum = tuple(int(part) for part in minimum_version.split("."))
current = tuple(int(part) for part in match.groups())
if current < minimum:
    raise SystemExit(f"plugin {version} is older than supported {minimum_version}")
print(version)
' "$2" "$MINIMUM_VERSION" || fail_with_rollback "Codex reported success but the installed plugin identity or version could not be verified."
}

while test "$#" -gt 0; do
  case "$1" in
    --source)
      test "$#" -ge 2 || fail "--source requires OWNER/REPO or an HTTPS GitHub URL."
      test -z "$SOURCE" || fail "only one GitHub source may be provided."
      SOURCE=$2
      shift 2
      ;;
    --offline)
      OFFLINE=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --*)
      fail "unknown option: $1"
      ;;
    *)
      test -z "$SOURCE" || fail "only one GitHub source may be provided."
      SOURCE=$1
      shift
      ;;
  esac
done

test "$OFFLINE" -eq 0 || test -z "$SOURCE" || fail "--offline cannot be combined with a GitHub source."
if test "$OFFLINE" -eq 0 && test -z "$SOURCE"; then
  usage >&2
  fail "provide a published GitHub repository, or use --offline with an extracted ZIP."
fi
if test "$OFFLINE" -eq 0; then
  requested_source=$(canonical_git_source "$SOURCE")
fi

command -v codex >/dev/null 2>&1 || fail "the Codex CLI is not available in PATH."
command -v python3 >/dev/null 2>&1 || fail "Python 3 is required to verify Codex results safely."
marketplace_json=$(codex plugin marketplace list --json) || fail "Codex could not list plugin marketplaces."
marketplace_details=$(inspect_marketplace "$marketplace_json") || fail "Codex returned invalid marketplace information."
marketplace_kind=$(printf '%s\n' "$marketplace_details" | sed -n '1p')
configured_source=$(printf '%s\n' "$marketplace_details" | sed -n '2p')
configured_ref=$(printf '%s\n' "$marketplace_details" | sed -n '3p')
expected_version=""

if test "$OFFLINE" -eq 1; then
  test -f "$PACKAGE_ROOT/.agents/plugins/marketplace.json" || fail "marketplace.json is missing. Extract the complete ZIP before installing."
  plugin_file="$PACKAGE_ROOT/plugins/open-study/.codex-plugin/plugin.json"
  test -f "$plugin_file" || fail "the Open Study plugin source is missing."
  expected_version=$(python3 -c '
import json, sys
with open(sys.argv[1], encoding="utf-8") as source:
    payload = json.load(source)
minimum = tuple(int(part) for part in sys.argv[2].split("."))
found = payload.get("version", "")
try:
    parsed = tuple(int(part) for part in found.split("."))
except ValueError:
    raise SystemExit(1)
if payload.get("name") != "open-study" or parsed < minimum:
    raise SystemExit(1)
print(found)
' "$plugin_file" "$MINIMUM_VERSION") || fail "the extracted ZIP is not an approved Open Study package (need v$MINIMUM_VERSION or newer)."

  case "$marketplace_kind" in
    missing)
      add_marketplace "$PACKAGE_ROOT"
      marketplace_json=$(codex plugin marketplace list --json) || fail_with_rollback "Codex could not verify the newly added local marketplace."
      marketplace_details=$(inspect_marketplace "$marketplace_json") || fail_with_rollback "Codex returned invalid marketplace information after adding the local source."
      marketplace_kind=$(printf '%s\n' "$marketplace_details" | sed -n '1p')
      configured_source=$(printf '%s\n' "$marketplace_details" | sed -n '2p')
      ;;
    local) ;;
    git)
      fail "the $MARKETPLACE_NAME marketplace already follows GitHub. It was left unchanged; use the update script instead."
      ;;
    duplicate)
      fail "more than one marketplace named $MARKETPLACE_NAME is configured. Resolve the duplicate before retrying."
      ;;
    *)
      fail "the existing $MARKETPLACE_NAME marketplace source could not be verified, so it was left unchanged."
      ;;
  esac

  test "$marketplace_kind" = "local" || fail_with_rollback "the newly added source did not register the expected local marketplace."
  if test -d "$configured_source"; then
    configured_root=$(CDPATH= cd -- "$configured_source" && pwd -P)
  else
    configured_root=$configured_source
  fi
  test "$configured_root" = "$PACKAGE_ROOT" || fail_with_rollback "a different local marketplace named $MARKETPLACE_NAME is configured. It was left unchanged."
  installed_from="the offline ZIP"
else
  case "$marketplace_kind" in
    missing)
      add_marketplace "$SOURCE" --ref "$GIT_REF"
      marketplace_json=$(codex plugin marketplace list --json) || fail_with_rollback "Codex could not verify the newly added GitHub marketplace."
      marketplace_details=$(inspect_marketplace "$marketplace_json") || fail_with_rollback "Codex returned invalid marketplace information after adding the GitHub source."
      marketplace_kind=$(printf '%s\n' "$marketplace_details" | sed -n '1p')
      configured_source=$(printf '%s\n' "$marketplace_details" | sed -n '2p')
      configured_ref=$(printf '%s\n' "$marketplace_details" | sed -n '3p')
      ;;
    local)
      fail "a local ZIP marketplace named $MARKETPLACE_NAME is already configured. It was left unchanged; follow the documented migration before switching to GitHub."
      ;;
    git) ;;
    duplicate)
      fail "more than one marketplace named $MARKETPLACE_NAME is configured. Resolve the duplicate before retrying."
      ;;
    *)
      fail "the existing $MARKETPLACE_NAME marketplace source could not be verified, so it was left unchanged."
      ;;
  esac

  test "$marketplace_kind" = "git" || fail_with_rollback "the selected repository did not register the expected Git marketplace."
  test -n "$configured_source" || fail_with_rollback "the configured Git marketplace did not report its source. It was left unchanged."
  configured_canonical=$(canonical_git_source "$configured_source") || fail_with_rollback "the configured Git marketplace reported an invalid GitHub source."
  test "$configured_canonical" = "$requested_source" || fail_with_rollback "the $MARKETPLACE_NAME marketplace points to a different GitHub repository. It was left unchanged."
  test "$configured_ref" = "$GIT_REF" || fail_with_rollback "the $MARKETPLACE_NAME marketplace is not pinned to the verified $GIT_REF ref. It was left unchanged."
  if test -z "$ADDED_MARKETPLACE"; then
    codex plugin marketplace upgrade "$MARKETPLACE_NAME" --json >/dev/null || fail "Codex could not refresh the GitHub marketplace. The installed plugin was left unchanged."
  fi
  installed_from=$configured_canonical
fi

if ! install_json=$(codex plugin add "$PLUGIN_NAME@$MARKETPLACE_NAME" --json); then
  fail_with_rollback "Codex could not install the Open Study plugin. Any previous installation was left unchanged."
fi
installed_version=$(verify_install_result "$install_json" "$expected_version")
ADDED_MARKETPLACE=""

printf '%s\n' "Open Study $installed_version is installed from $installed_from. Start a new Codex task to load the updated Skill and MCP connection."
