#!/bin/bash

# Intent: Boot a CI-created simulator with diagnostics, surfacing exit codes for RCA.

set -euo pipefail

UDID="${SIMULATOR_UDID:-}"
NAME="${SIMULATOR_NAME:-}"

if [ -z "$UDID" ] || [ -z "$NAME" ]; then
    echo "❌ SIMULATOR_UDID and SIMULATOR_NAME must be set before booting."
    exit 1
fi

log() { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*"; }

log "Preparing to boot simulator $NAME ($UDID)"

echo "-- Current simulator state --"
xcrun simctl list devices "$UDID" || true

start=$(date +%s)
boot_rc=0
xcrun simctl boot "$UDID" || boot_rc=$?
log "simctl boot exit code: $boot_rc"

bootstatus_rc=0
xcrun simctl bootstatus "$UDID" -b -t 180 || bootstatus_rc=$?
log "simctl bootstatus exit code: $bootstatus_rc"

if [ "$bootstatus_rc" -ne 0 ]; then
    log "Bootstatus failed; capturing diagnostics"
    xcrun simctl list devices "$UDID" || true
    xcrun simctl diagnose -b || true
    log "Recent launchd_sim logs:"
    log show --last 10m --predicate 'process == "launchd_sim"' --style compact || true
    exit "$bootstatus_rc"
fi

end=$(date +%s)
log "Simulator boot ready in $((end - start))s"
exit 0
