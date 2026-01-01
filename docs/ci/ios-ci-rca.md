<!-- Intent: Track iOS CI failures and applied fixes to avoid rework. -->

# iOS CI RCA Log

## Scope
This document tracks failed GitHub Actions runs, observed symptoms, and fixes
applied so we do not retry the same changes.

## Current Status
- Latest run: 20646427000 (PR #17) failed in "Build iOS App".
- Symptom: `xcodebuild -showdestinations` lists only an ineligible iOS device
  placeholder and no iOS Simulator destinations. Build fails with
  "Unable to find a destination matching the provided destination specifier."

## Applied Fixes (Chronological)

| Date | Commit | Change | Evidence | Result |
| --- | --- | --- | --- | --- |
| 2026-01-01 | 812f8bb | Fix deployment target from 26.2 to 17.0. | N/A | Did not resolve simulator destination issue. |
| 2026-01-01 | 787605e | Add initial iOS CI workflow. | N/A | CI runs failed to find simulator destinations. |
| 2026-01-01 | d86e279 | Remove `OS=latest` from simulator destination. | Run 20644510607 | Still failed to find destination. |
| 2026-01-01 | 4e3cd1a | Use generic iOS Simulator destination. | Run 20644510607 | Still failed to find destination. |
| 2026-01-01 | b593a30 | Use recommended destination pattern + diagnostics. | Run 20644585026 | Still failed to find destination. |
| 2026-01-01 | 2120a4c | Add SDK listing to debug platform availability. | Run 20644627990 | Still failed to find destination. |
| 2026-01-01 | 33c3042 | Explicitly specify iOS Simulator SDK. | Run 20644654196 | Still failed to find destination. |
| 2026-01-01 | 0c33369 | Add `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"` at project level. | Run 20644872115 | Still failed to find destination. |
| 2026-01-01 | 7cc9490 | Select available simulator by UDID in CI. | Run 20646313834 | Still failed to find destination. |
| 2026-01-01 | a2286b8 | Add `SUPPORTED_PLATFORMS` to offload target configs. | Run 20646427000 | Still failed to find destination. |


## Additional Findings
- `origin/feature/ci-workflows` already includes multiple destination tweaks
  and the project-level `SUPPORTED_PLATFORMS` change (commit `0c33369`), but
  no other simulator-enabling changes.
- `ios/Offload.xcodeproj/project.pbxproj` shows `CreatedOnToolsVersion = 26.2`
  and `objectVersion = 77`, which may require a newer Xcode than 16.0 for
  simulator destinations to appear.
- No `.xcconfig` files exist; workspace settings are empty at
  `ios/Offload.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings`.
- CI now logs build settings for the simulator SDK before the build step
  to surface effective values like `SUPPORTED_PLATFORMS` and `SDKROOT`.

## Known Non-Solutions
- Simulator destination string changes alone do not fix the issue.
- Adding simulator selection by UDID in CI does not fix the issue.
- Adding `SUPPORTED_PLATFORMS` at the project level alone does not fix the issue.

## Next Checks (Not Yet Applied)
- Inspect for build settings that override `SUPPORTED_PLATFORMS` or restrict
  `SUPPORTED_DEVICE_FAMILY` on the offload target during CI.
- Validate the shared scheme in Xcode to ensure it targets iOS (not visionOS)
  and that the `offload` target is selected for iOS Simulator builds.
