#!/usr/bin/env bash
# Intent: Deterministically build the Offload iOS app for CI with stable paths and simulator targets.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${REPO_ROOT}/scripts/ci/readiness_env.sh"

PROJECT_PATH="${PROJECT_PATH:-${REPO_ROOT}/ios/Offload.xcodeproj}"
SCHEME="${SCHEME:-Offload}"
CONFIGURATION="${CONFIGURATION:-Debug}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${REPO_ROOT}/.ci/DerivedData}"
SIM_SELECTOR="${SCRIPT_DIR}/select-simulator.sh"
PRE_FLIGHT_SCRIPT="${SCRIPT_DIR}/preflight.sh"

info() {
  echo "[INFO] $*"
}

main() {
  if [[ ! -x "${PRE_FLIGHT_SCRIPT}" ]]; then
    PRE_FLIGHT_SCRIPT="${REPO_ROOT}/scripts/ios/preflight.sh"
  fi

  if [[ ! -x "${PRE_FLIGHT_SCRIPT}" ]]; then
    echo "[ERROR] Preflight script not found. Expected at ${SCRIPT_DIR}/preflight.sh" >&2
    exit 1
  fi

  "${PRE_FLIGHT_SCRIPT}"

  if [[ ! -x "${SIM_SELECTOR}" ]]; then
    echo "[ERROR] Simulator selector not found at ${SIM_SELECTOR}" >&2
    exit 1
  fi

  info "Selecting simulator UDID via ${SIM_SELECTOR}"
  local selection_output
  if ! selection_output="$("${SIM_SELECTOR}")"; then
    echo "[ERROR] Failed to select simulator UDID." >&2
    printf "%s\n" "${selection_output:-<no output>}" >&2
    exit 1
  fi

  printf "%s\n" "${selection_output}"
  local selected_udid
  selected_udid="$(printf "%s\n" "${selection_output}" | tail -n 1)"
  local destination="platform=iOS Simulator,id=${selected_udid}"

  mkdir -p "${DERIVED_DATA_PATH}"

  info "Building scheme '${SCHEME}' with configuration '${CONFIGURATION}'."
  info "DerivedData: ${DERIVED_DATA_PATH}"
  info "Destination: ${destination}"

  xcodebuild \
    -project "${PROJECT_PATH}" \
    -scheme "${SCHEME}" \
    -configuration "${CONFIGURATION}" \
    -destination "${destination}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    COMPILER_INDEX_STORE_ENABLE=NO \
    build
}

main "$@"
