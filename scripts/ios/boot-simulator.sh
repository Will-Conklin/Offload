#!/usr/bin/env bash
# Intent: Reliably boot a simulator UDID with retries, cleanup, and diagnostics to reduce CI flakiness.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

UDID="${1:-}"
BOOT_TIMEOUT="${BOOT_TIMEOUT:-240}"
MAX_RETRIES="${MAX_BOOT_RETRIES:-3}"

if [[ -z "${UDID}" ]]; then
  echo "Usage: ${0} <simulator-udid>" >&2
  exit 1
fi

info() {
  echo "[INFO] $*" >&2
}

warn() {
  echo "[WARN] $*" >&2
}

diagnostics() {
  warn "Boot diagnostics for ${UDID}:"
  {
    echo "=== Simulator Runtimes ==="
    xcrun simctl list runtimes
    echo
    echo "=== Simulator Devices ==="
    xcrun simctl list devices
  } >&2

  if command -v xcrun >/dev/null 2>&1; then
    warn "simctl diagnose (best-effort):"
    if ! xcrun simctl diagnose >&2; then
      warn "simctl diagnose failed; continuing."
    fi
  fi
}

shutdown_device() {
  xcrun simctl shutdown "${UDID}" >/dev/null 2>&1 || true
}

erase_device() {
  if ! xcrun simctl erase "${UDID}" >/dev/null 2>&1; then
    warn "Erase failed for ${UDID}; continuing."
  fi
}

boot_once() {
  shutdown_device
  xcrun simctl boot "${UDID}"

  # Wait for boot status (without -t flag for compatibility with older Xcode versions)
  # Use a manual timeout loop instead
  local start_time=$(date +%s)
  local timeout_reached=false

  while true; do
    if xcrun simctl bootstatus "${UDID}" -b 2>/dev/null; then
      return 0
    fi

    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))

    if (( elapsed >= BOOT_TIMEOUT )); then
      timeout_reached=true
      return 1
    fi

    sleep 2
  done
}

main() {
  info "Booting simulator ${UDID} with timeout ${BOOT_TIMEOUT}s (max ${MAX_RETRIES} attempts)."

  local attempt=1
  while (( attempt <= MAX_RETRIES )); do
    info "Boot attempt ${attempt}/${MAX_RETRIES} for ${UDID}"
    if boot_once; then
      info "Simulator ${UDID} booted successfully."
      return 0
    fi

    warn "Simulator boot attempt ${attempt} failed for ${UDID}. Retrying with cleanup."
    (( attempt++ ))
    shutdown_device
    erase_device
  done

  diagnostics
  warn "All boot attempts failed for ${UDID}."
  exit 1
}

main "$@"
