#!/usr/bin/env bash
# Intent: Parse pinned CI environment values strictly from docs/ci/ci-readiness.md and export them for workflows.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DOC_PATH="${REPO_ROOT}/docs/ci/ci-readiness.md"

SECTION_START_PATTERN='^## Pinned CI Environment$'
KEY_PATTERN='^(CI_MACOS_RUNNER|CI_XCODE_VERSION|CI_SIM_DEVICE|CI_SIM_OS):[[:space:]]*(.+)$'

err() {
  echo "docs/ci/ci-readiness.md Pinned CI Environment section is missing a required key or value" >&2
}

parse_values() {
  local in_section=false
  local ci_macos_runner=""
  local ci_xcode_version=""
  local ci_sim_device=""
  local ci_sim_os=""
  local ci_sim_os_resolved=""

  while IFS= read -r line; do
    if [[ ${in_section} == false ]]; then
      if [[ ${line} =~ ${SECTION_START_PATTERN} ]]; then
        in_section=true
      fi
      continue
    fi

    if [[ ${line} =~ ^##[[:space:]] ]]; then
      break
    fi

    if [[ ${line} =~ ${KEY_PATTERN} ]]; then
      local key="${BASH_REMATCH[1]}"
      local value="${BASH_REMATCH[2]}"
      if [[ -n ${value} ]]; then
        case "${key}" in
          CI_MACOS_RUNNER) ci_macos_runner="${value}" ;;
          CI_XCODE_VERSION) ci_xcode_version="${value}" ;;
          CI_SIM_DEVICE) ci_sim_device="${value}" ;;
          CI_SIM_OS) ci_sim_os="${value}" ;;
        esac
      fi
    fi
  done <"${DOC_PATH}"

  for required_key in CI_MACOS_RUNNER CI_XCODE_VERSION CI_SIM_DEVICE CI_SIM_OS; do
    case "${required_key}" in
      CI_MACOS_RUNNER)
        [[ -z ${ci_macos_runner} ]] && return 1
        ;;
      CI_XCODE_VERSION)
        [[ -z ${ci_xcode_version} ]] && return 1
        ;;
      CI_SIM_DEVICE)
        [[ -z ${ci_sim_device} ]] && return 1
        ;;
      CI_SIM_OS)
        [[ -z ${ci_sim_os} ]] && return 1
        ;;
    esac
  done

  if [[ ${ci_sim_os} == "latest" ]]; then
    if ! command -v xcrun >/dev/null 2>&1; then
      echo "CI_SIM_OS=latest requires xcrun to resolve the newest installed iOS runtime" >&2
      return 1
    fi

    local runtimes_json
    if ! runtimes_json="$(xcrun simctl list runtimes --json 2>/dev/null)"; then
      echo "Unable to query simulator runtimes via xcrun simctl list runtimes --json" >&2
      return 1
    fi

    if ! ci_sim_os_resolved="$(python3 - <<'PY'
import json
import sys

try:
    runtimes = json.load(sys.stdin).get("runtimes", [])
except json.JSONDecodeError:
    sys.exit(1)

versions = []
for runtime in runtimes:
    if runtime.get("platform") != "iOS":
        continue
    if runtime.get("isAvailable") is False:
        continue
    version = runtime.get("version")
    if not version:
        continue
    try:
        parts = tuple(int(part) for part in version.split("."))
    except ValueError:
        continue
    versions.append((parts, version))

if not versions:
    sys.exit(1)

versions.sort()
print(versions[-1][1])
PY
    )"; then
      echo "Failed to resolve the latest available iOS simulator runtime version" >&2
      return 1
    fi
  else
    ci_sim_os_resolved="${ci_sim_os}"
  fi

  export CI_MACOS_RUNNER="${ci_macos_runner}"
  export CI_XCODE_VERSION="${ci_xcode_version}"
  export CI_SIM_DEVICE="${ci_sim_device}"
  export CI_SIM_OS="${ci_sim_os}"
  export CI_SIM_OS_RESOLVED="${ci_sim_os_resolved}"
}

main() {
  if [[ ! -f "${DOC_PATH}" ]]; then
    err
    exit 1
  fi

  if ! parse_values; then
    err
    exit 1
  fi
}

main "$@"
