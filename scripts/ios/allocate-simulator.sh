#!/bin/bash

# Intent: Allocate a fresh iPhone simulator for CI, preferring modern devices and exporting metadata for downstream steps.

set -euo pipefail

echo "=== Allocating simulator for CI ==="

PREFERRED_DEVICES=(
    "iPhone 16 Pro"
    "iPhone 16"
    "iPhone 15 Pro"
    "iPhone 15"
    "iPhone 14 Pro"
    "iPhone 14"
)

echo "-- Listing runtimes --"
xcrun simctl list runtimes

echo "-- Listing device types --"
xcrun simctl list devicetypes | head -n 100

python3 <<'PY'
import json
import os
import subprocess
import sys

preferred_devices = [
    "iPhone 16 Pro",
    "iPhone 16",
    "iPhone 15 Pro",
    "iPhone 15",
    "iPhone 14 Pro",
    "iPhone 14",
]


def version_tuple(version: str) -> tuple[int, ...]:
    parts = []
    current = ""
    for ch in version:
        if ch.isdigit():
            current += ch
        elif current:
            parts.append(int(current))
            current = ""
    if current:
        parts.append(int(current))
    return tuple(parts) or (0,)


def run_json(args: list[str]) -> dict:
    try:
        raw = subprocess.check_output(args)
    except subprocess.CalledProcessError as exc:
        print(f"Command failed: {' '.join(args)}", file=sys.stderr)
        print(exc, file=sys.stderr)
        sys.exit(1)
    return json.loads(raw)


runtimes = run_json(["xcrun", "simctl", "list", "runtimes", "-j"]).get(
    "runtimes", []
)
ios_runtimes = [
    rt
    for rt in runtimes
    if rt.get("isAvailable") and "iOS" in rt.get("name", "")
]

if not ios_runtimes:
    print("No available iOS runtimes found", file=sys.stderr)
    sys.exit(1)

ios_runtimes.sort(key=lambda rt: version_tuple(rt.get("version", "0")), reverse=True)
runtime = ios_runtimes[0]

devicetypes = run_json(["xcrun", "simctl", "list", "devicetypes", "-j"]).get(
    "devicetypes", []
)

selected_type = None
for name in preferred_devices:
    for dev_type in devicetypes:
        if dev_type.get("name") == name:
            selected_type = dev_type
            break
    if selected_type:
        break

if selected_type is None:
    for dev_type in devicetypes:
        if "iPhone" in dev_type.get("name", ""):
            selected_type = dev_type
            break

if selected_type is None:
    print("No iPhone device types available", file=sys.stderr)
    sys.exit(1)

sim_name = f"CI {selected_type['name']} ({runtime['version']})"
create_cmd = [
    "xcrun",
    "simctl",
    "create",
    sim_name,
    selected_type["identifier"],
    runtime["identifier"],
]

result = subprocess.run(create_cmd, capture_output=True, text=True)
if result.returncode != 0:
    print("Failed to create simulator", file=sys.stderr)
    print(result.stdout, file=sys.stderr)
    print(result.stderr, file=sys.stderr)
    sys.exit(result.returncode)

udid = result.stdout.strip()
print(f"Selected runtime: {runtime['name']} ({runtime['identifier']})")
print(f"Selected device type: {selected_type['name']} ({selected_type['identifier']})")
print(f"Created simulator: {sim_name} ({udid})")

env_path = os.environ.get("GITHUB_ENV")
for key, value in [
    ("SIMULATOR_UDID", udid),
    ("SIMULATOR_NAME", sim_name),
    ("SIMULATOR_RUNTIME", runtime.get("identifier", "")),
    ("SIMULATOR_RUNTIME_VERSION", runtime.get("version", "")),
    ("SIMULATOR_DEVICE_TYPE", selected_type.get("identifier", "")),
]:
    line = f"{key}={value}\n"
    sys.stdout.write(line)
    if env_path:
        with open(env_path, "a", encoding="utf-8") as env_file:
            env_file.write(line)
PY

echo "-- Listing available devices after creation --"
xcrun simctl list devices available iPhone || true

exit 0
