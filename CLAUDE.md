# Taco Bell Watch

## TestFlight Upload Process

Standalone watchOS apps require an iOS stub container for App Store Connect submission.

### 1. Bump build number
Update `CURRENT_PROJECT_VERSION` in `project.yml` for both targets (TacoBellWatchStub and TacoBellWatch).

### 2. Regenerate & Archive
```bash
xcodegen generate
xcodebuild archive \
  -project TacoBellWatch.xcodeproj \
  -scheme TacoBellWatchStub \
  -configuration Release \
  -archivePath build/TacoBellWatch.xcarchive \
  -allowProvisioningUpdates
```

### 3. Upload
```bash
xcodebuild -exportArchive \
  -archivePath build/TacoBellWatch.xcarchive \
  -exportOptionsPlist build/ExportOptions.plist \
  -allowProvisioningUpdates
```

Verify with `Upload succeeded` and `EXPORT SUCCEEDED` in output.

### Key Details
- Archive scheme: **TacoBellWatchStub** (iOS stub that embeds watchOS app)
- Bundle IDs: `com.tacobellwatch.app` (iOS), `com.tacobellwatch.app.watchkitapp` (watchOS)
- Team ID: `264SGEWUH5`
- Apple ID: `6761598622`
- Auth: `-allowProvisioningUpdates` (no API key needed)
- ExportOptions: `build/ExportOptions.plist` (method: app-store, destination: upload, automatic signing)
