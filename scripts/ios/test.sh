#!/usr/bin/env bash
# Intent: Run deterministic iOS simulator tests with explicit destinations and captured result bundles.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

PROJECT_PATH="${PROJECT_PATH:-${REPO_ROOT}/ios/Offload.xcodeproj}"
SCHEME="${SCHEME:-Offload}"
CONFIGURATION="${CONFIGURATION:-Debug}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${REPO_ROOT}/.ci/DerivedData}"
RESULT_BUNDLE_PATH="${RESULT_BUNDLE_PATH:-${REPO_ROOT}/.ci/TestResults.xcresult}"
SIM_SELECTOR="${SCRIPT_DIR}/select-simulator.sh"

info() {
  echo "[INFO] $*"
}

warn() {
  echo "[WARN] $*" >&2
}

print_versions() {
  info "xcodebuild version:"
  xcodebuild -version || warn "Unable to read xcodebuild version."

  if command -v sw_vers >/dev/null 2>&1; then
    info "macOS version:"
    sw_vers
  else
    warn "sw_vers not available (expected on macOS)."
  fi
}

main() {
  print_versions
  "${SCRIPT_DIR}/preflight.sh"

  if [[ ! -x "${SIM_SELECTOR}" ]]; then
    warn "Simulator selector not found at ${SIM_SELECTOR}"
    exit 1
  fi

  info "Selecting simulator UDID via ${SIM_SELECTOR}"
  local selection_output
  if ! selection_output="$("${SIM_SELECTOR}")"; then
    warn "Failed to select simulator UDID."
    printf "%s\n" "${selection_output:-<no output>}" >&2
    exit 1
  fi

  printf "%s\n" "${selection_output}"
  local selected_udid
  selected_udid="$(printf "%s\n" "${selection_output}" | tail -n 1)"
  local destination="platform=iOS Simulator,id=${selected_udid}"

  mkdir -p "$(dirname "${RESULT_BUNDLE_PATH}")"
  rm -rf "${RESULT_BUNDLE_PATH}"
  mkdir -p "${DERIVED_DATA_PATH}"

  info "Testing scheme '${SCHEME}' on '${destination}'."
  info "Result bundle: ${RESULT_BUNDLE_PATH}"
  info "DerivedData: ${DERIVED_DATA_PATH}"

  set +e
  xcodebuild \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -destination "${destination}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -resultBundlePath "${RESULT_BUNDLE_PATH}" \
    COMPILER_INDEX_STORE_ENABLE=NO \
    test
  status=$?
  set -e

  if [[ -d "${RESULT_BUNDLE_PATH}" ]]; then
    info "Result bundle saved to ${RESULT_BUNDLE_PATH}"
  else
    warn "Result bundle not found at ${RESULT_BUNDLE_PATH}"
  fi

  exit "${status}"
}

main "$@"
