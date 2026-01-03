#!/usr/bin/env bash
# Intent: Select a deterministic available simulator UDID using CI-pinned preferences with a clear fallback log.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${REPO_ROOT}/scripts/ci/readiness_env.sh"

info() {
  echo "[INFO] $*"
}

warn() {
  echo "[WARN] $*" >&2
}

select_simulator() {
  python3 - <<'PY'
import json
import os
import re
import sys
import traceback

ci_device = os.environ.get("CI_SIM_DEVICE", "").strip()
ci_os = os.environ.get("CI_SIM_OS", "").strip()


def format_version(version_tuple: tuple[int, ...]) -> str:
  return ".".join(str(part) for part in version_tuple) if version_tuple else ""


def version_tuple_from_string(value: str) -> tuple[int, ...]:
  normalized = value.replace("-", ".")
  matches = re.findall(r"\d+(?:\.\d+)*", normalized)
  if not matches:
    return ()
  version = matches[0]
  try:
    return tuple(int(part) for part in version.split("."))
  except ValueError:
    return ()


def available_devices(runtime_key: str, payload: dict) -> list[dict]:
  devices = []
  for device in payload.get(runtime_key, []):
    if not device.get("isAvailable"):
      continue
    udid = device.get("udid", "").strip()
    name = device.get("name", "").strip()
    if not udid or not name:
      continue
    devices.append({"udid": udid, "name": name})
  return devices


def find_device_by_name(devices: list[dict], preferred: str) -> dict | None:
  if not preferred:
    return None
  preferred_lower = preferred.lower()
  matches = [d for d in devices if d["name"].lower() == preferred_lower]
  if not matches:
    return None
  return sorted(matches, key=lambda d: (d["name"], d["udid"]))[0]


def find_first_iphone(devices: list[dict]) -> dict | None:
  iphones = [d for d in devices if "iphone" in d["name"].lower()]
  if not iphones:
    return None
  return sorted(iphones, key=lambda d: (d["name"], d["udid"]))[0]


try:
  devices_json = json.load(sys.stdin)
  devices_payload = devices_json.get("devices", {}) if isinstance(devices_json, dict) else {}
except Exception:
  traceback.print_exc()
  sys.exit(1)

runtime_entries: list[tuple[tuple[int, ...], str, list[dict]]] = []

for runtime_key in devices_payload.keys():
  if "ios" not in runtime_key.lower():
    continue
  version_tuple = version_tuple_from_string(runtime_key)
  available = available_devices(runtime_key, devices_payload)
  if not version_tuple or not available:
    continue
  runtime_entries.append((version_tuple, runtime_key, available))

if not runtime_entries:
  print("[WARN] No available iOS simulators found.")
  sys.exit(1)

pinned_version = version_tuple_from_string(ci_os)
messages: list[str] = []

preferred_label = f"device '{ci_device}' on iOS {ci_os}" if ci_device or ci_os else "(no pinned simulator preferences)"
messages.append(f"[INFO] Preferred simulator from docs: {preferred_label}")

selected_runtime: tuple[int, ...] | None = None
selected_runtime_key: str | None = None
selected_device: dict | None = None
fallback_reason: str | None = None

if pinned_version:
  matching_runtimes = sorted(
    [entry for entry in runtime_entries if entry[0] == pinned_version],
    key=lambda entry: entry[1],
  )
  for runtime_version, runtime_key, devices in matching_runtimes:
    device_match = find_device_by_name(devices, ci_device)
    if device_match:
      selected_runtime = runtime_version
      selected_runtime_key = runtime_key
      selected_device = device_match
      break
  if selected_device:
    messages.append(
      f"[INFO] Using pinned runtime {format_version(selected_runtime)} ({selected_runtime_key}) with device '{selected_device['name']}'."
    )
  elif matching_runtimes:
    fallback_reason = (
      f"Device '{ci_device}' not found under runtime {matching_runtimes[0][1]}; using newest available runtime instead."
    )
  else:
    fallback_reason = "Pinned runtime is not installed; using newest available runtime instead."

if selected_device is None:
  newest_runtime_version, newest_runtime_key, devices = sorted(
    runtime_entries,
    key=lambda entry: (entry[0], entry[1]),
    reverse=True,
  )[0]

  device_match = find_device_by_name(devices, ci_device)
  if device_match:
    selected_device = device_match
    fallback_reason = fallback_reason or "Pinned runtime unavailable; matched device on newest runtime."
  else:
    iphone_match = find_first_iphone(devices)
    if iphone_match:
      selected_device = iphone_match
      fallback_reason = fallback_reason or "Pinned device unavailable; using first available iPhone on newest runtime."
    else:
      selected_device = sorted(devices, key=lambda d: (d["name"], d["udid"]))[0]
      fallback_reason = fallback_reason or "No iPhone simulators available; using first available simulator on newest runtime."

  selected_runtime = newest_runtime_version
  selected_runtime_key = newest_runtime_key

if selected_device is None or selected_runtime is None or selected_runtime_key is None:
  print("[WARN] Unable to select a simulator from available runtimes.")
  sys.exit(1)

if fallback_reason:
  messages.append(f"[INFO] Fallback applied: {fallback_reason}")

runtime_label = format_version(selected_runtime)
messages.append(
  f"[INFO] Selected simulator: {selected_device['name']} (iOS {runtime_label}; runtime={selected_runtime_key}) [{selected_device['udid']}]"
)

for line in messages:
  print(line)

print(selected_device["udid"])
PY
}

main() {
  if ! command -v xcrun >/dev/null 2>&1; then
    warn "xcrun is required to enumerate simulators."
    exit 1
  fi

  info "Reading simulator preferences from docs/ci/ci-readiness.md"

  if ! simctl_output="$(xcrun simctl list -j devices available)"; then
    warn "Failed to query available simulators via simctl."
    exit 1
  fi

  select_simulator <<<"${simctl_output}"
}

main "$@"
