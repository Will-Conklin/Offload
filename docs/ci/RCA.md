<!-- Intent: Capture RCA for the simulator boot exit 117 and coverage exit 1 failures in iOS CI. -->

# iOS CI Failure RCA (Run 20662961598)

## Summary
- The **Boot simulator (timed)** step exited with status **117** because `xcrun simctl bootstatus ... -s` only checks state and returns non-zero when the device is not yet booted. The workflow queried status immediately after issuing `simctl boot`, so slower boots caused a non-zero exit without diagnostics. Tests never started, preventing `ios/TestResults.xcresult` from being written.
- The **Generate coverage report** step failed with exit code **1** because it called `xcrun xccov view --report --json ios/TestResults.xcresult` when that bundle was absent.

## Evidence
- Workflow commands from `.github/workflows/ios-ci.yml` (pre-fix):
  - Boot: `xcrun simctl boot "$SIMULATOR_UDID"` then `xcrun simctl bootstatus "$SIMULATOR_UDID" -b -s`.
  - Tests: `xcodebuild test-without-building ... -resultBundlePath "$TEST_RESULT_PATH" -enableCodeCoverage YES`.
  - Coverage: `xcrun xccov view --report --json "$TEST_RESULT_PATH"`.
- Failed job summary included `Boot simulator (timed)` exit code **117** and `Generate coverage report` exit code **1**, and no `ios/TestResults.xcresult` artifact was produced.

## Fix
- Add full simulator diagnostics (toolchain versions, runtimes, device types, available devices, booted devices) before allocation.
- Create a fresh simulator via `scripts/ios/allocate-simulator.sh`, selecting the newest available iOS runtime and a preferred iPhone device type.
- Replace the boot step with `scripts/ios/boot-simulator.sh`, which logs exit codes for `simctl boot` and `simctl bootstatus -b -t 180`, and emits `simctl diagnose` plus `launchd_sim` logs on failure.
- Gate coverage generation on the presence of `ios/TestResults.xcresult`; emit a clear error when missing and downgrade artifact upload failures to warnings.

## Command Lines (post-fix)
- Simulator creation: `bash scripts/ios/allocate-simulator.sh` (selects runtime/device and exports `SIMULATOR_UDID`/`SIMULATOR_NAME`).
- Boot: `bash scripts/ios/boot-simulator.sh` (internally runs `xcrun simctl boot ...` + `xcrun simctl bootstatus ... -b -t 180`).
- Tests: `xcodebuild test-without-building -project ios/Offload.xcodeproj -scheme offload -sdk iphonesimulator -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" -derivedDataPath ios/DerivedData -resultBundlePath ios/TestResults.xcresult -enableCodeCoverage YES -destination-timeout 120`.
- Coverage: `xcrun xccov view --report --json ios/TestResults.xcresult` (only when the bundle exists).
