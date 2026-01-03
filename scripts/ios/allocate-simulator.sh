#!/usr/bin/env bash
# Intent: Allocate a deterministic available simulator UDID matching preferred name/runtime for CI workflows.

set -euo pipefail

PREFERRED_DEVICE_NAME="${DEVICE_NAME:-${PREFERRED_DEVICE_NAME:-iPhone 15}}"
PREFERRED_RUNTIME="${OS_VERSION:-${PREFERRED_RUNTIME:-}}"
PREFERRED_RUNTIME_IDENTIFIER="${SIM_RUNTIME_IDENTIFIER:-${SIM_RUNTIME:-${PREFERRED_RUNTIME_IDENTIFIER:-}}}"

info() {
  echo "[INFO] $*" >&2
}

warn() {
  echo "[WARN] $*" >&2
}

select_simulator() {
  python3 - <<'PY'
import json
import os
import sys
import traceback

preferred_name = os.environ.get("PREFERRED_DEVICE_NAME", "").strip()
preferred_runtime = os.environ.get("PREFERRED_RUNTIME", "").strip()
preferred_runtime_id = os.environ.get("PREFERRED_RUNTIME_IDENTIFIER", "").strip()

try:
    data = json.load(sys.stdin)
    devices = data.get("devices", {})
except Exception:
    traceback.print_exc()
    sys.exit(1)

def runtime_score(runtime_identifier: str) -> int:
    if preferred_runtime_id:
        return 0 if runtime_identifier == preferred_runtime_id else 2
    if preferred_runtime:
        normalized = "".join(ch if ch.isalnum() else "-" for ch in preferred_runtime).lower()
        return 0 if normalized and normalized in runtime_identifier.lower() else 1
    return 1

def name_score(device_name: str) -> int:
    if preferred_name:
        if device_name.lower() == preferred_name.lower():
            return 0
        if preferred_name.lower() in device_name.lower():
            return 1
    return 2

candidates = []

for runtime_identifier in sorted(devices.keys()):
    for device in devices.get(runtime_identifier, []):
        if not device.get("isAvailable", False):
            continue
        udid = device.get("udid")
        name = device.get("name", "")
        if not udid:
            continue

        score = (
            runtime_score(runtime_identifier),
            name_score(name),
            runtime_identifier,
            name,
            udid,
        )
        candidates.append((score, runtime_identifier, name, udid))

if not candidates:
    print("No available simulators found.", file=sys.stderr)
    sys.exit(1)

candidates.sort(key=lambda entry: entry[0])
_, runtime_identifier, name, udid = candidates[0]

print(f"Selected simulator: {name} ({runtime_identifier}) [{udid}]", file=sys.stderr)
print(udid)
PY
}

main() {
  info "Selecting available simulator matching name='${PREFERRED_DEVICE_NAME}' runtime='${PREFERRED_RUNTIME_IDENTIFIER:-${PREFERRED_RUNTIME}}'"

  if ! output="$(xcrun simctl list -j devices available | select_simulator)"; then
    warn "Failed to select simulator."
    exit 1
  fi

  # output contains stderr logs + UDID; last line is UDID
  udid="$(printf "%s\n" "${output}" | tail -n 1)"
  printf "%s\n" "${udid}"
}

main "$@"
