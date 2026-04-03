# Focus Maltese Release Checklist

## App Store / TestFlight Prep
- Bundle identifier: `com.soleme.focusMaltese`
- Minimum iOS version: `15.0`
- Current version source: `pubspec.yaml`
- Current app display name: `집중해 말티즈`

## Before First Archive
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Set the correct Apple Developer Team in Signing & Capabilities.
   Current repo state: `DEVELOPMENT_TEAM` is not committed yet and must be set locally in Xcode.
3. Confirm `com.soleme.focusMaltese` is available in Apple Developer.
4. Verify notification capability and permission flow on a real device if alerts are required for release.
5. Replace placeholder Maltese images with final production artwork if needed.
6. Review app icon and launch screen on device and TestFlight build.

## Metadata To Prepare
- App subtitle
- App description
- Keywords
- Support URL
- Privacy policy URL
- App category
- Screenshots for iPhone sizes
- Optional App Preview video

Drafts prepared locally:
- `APP_STORE_METADATA.md`
- `PRIVACY.md`

## Functional Checks
- `fvm flutter analyze`
- `fvm flutter test`
- iPhone simulator launch
- Local notification permission request
- Local notification fires after focus session
- Settings reset flow
- Recent session records and weekly chart render correctly

## Nice To Finish Before Submission
- Replace remaining placeholder or cropped Maltese art with final polished assets
- Review Korean copy for brevity and consistency
- Test notification behavior when app is backgrounded
- Verify layout on smaller iPhones and larger Pro Max size
