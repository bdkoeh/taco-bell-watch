# Tbell Compass

An Apple Watch app that points you to the nearest Taco Bell. It's a compass, but for tacos.

Tap the taco to start scanning. The app finds the closest Taco Bell using MapKit, then gives you a live compass needle and distance readout so you can walk (or run) straight to it. When you're facing the right direction, it locks on with a sound and haptic.

## How it works

- Uses `MKLocalSearch` to find Taco Bell locations within ~10 miles
- Tracks device heading via CoreLocation to rotate the compass dial in real time
- Calculates bearing to the nearest result and places a taco marker on the compass perimeter
- Re-searches automatically when you move 500+ meters from the last search point
- Plays the Taco Bell bong + haptic when you're within 15 degrees of the target heading

## Requirements

- watchOS 10.0+
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## Building

```bash
xcodegen generate
open TacoBellWatch.xcodeproj
```

Select the **TacoBellWatch** scheme to run on a Watch simulator, or **TacoBellWatchStub** to archive for TestFlight (the iOS stub is required for App Store Connect submission).

## Project structure

```
TacoBellWatch/
  Views/          CompassView, StartView
  ViewModels/     CompassViewModel
  Services/       LocationService, TacoBellSearchService
  Utilities/      BearingCalculator, SoundPlayer, Colors
iOSStub/          Empty iOS host app for App Store Connect
project.yml       XcodeGen spec
```

## TestFlight

Available on TestFlight. Built and uploaded with:

```bash
xcodegen generate
xcodebuild archive \
  -project TacoBellWatch.xcodeproj \
  -scheme TacoBellWatchStub \
  -configuration Release \
  -archivePath build/TacoBellWatch.xcarchive \
  -allowProvisioningUpdates
xcodebuild -exportArchive \
  -archivePath build/TacoBellWatch.xcarchive \
  -exportOptionsPlist build/ExportOptions.plist \
  -allowProvisioningUpdates
```

## License

MIT
