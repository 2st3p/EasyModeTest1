# AGENTS.md

## Project Overview
Easymode is a focused iOS application that helps users concentrate on a single task by blocking distracting apps using Apple's Screen Time (FamilyControls) API.

## Build and Test Commands

### Build
```bash
./scripts/test.sh build
```

### Default Test
```bash
./scripts/test.sh unit
```

### Full Test Gate
```bash
./scripts/test.sh all
```

### Physical device (Erik)
Primary on-device test phone is an **iPhone 16 Pro**, renamed in Finder/Xcode as **iPod Nano** (nickname: ipod nano).

| Field | Value |
| --- | --- |
| Xcode / `xctrace` name | `iPod Nano` |
| UDID | `00008140-001244AC3062201C` |
| Bundle ID | `name.erikkernan.easymode` |

`./scripts/test.sh build` targets a simulator. To build, install, and launch on this device from the repo root:

```bash
xcodebuild -project easy-mode.xcodeproj -scheme Easymode -configuration Debug \
  -destination 'platform=iOS,id=00008140-001244AC3062201C' \
  -derivedDataPath .build/ios-device-ipod build && \
xcrun devicectl device install app --device 00008140-001244AC3062201C \
  .build/ios-device-ipod/Build/Products/Debug-iphoneos/Easymode.app && \
xcrun devicectl device process launch --device 00008140-001244AC3062201C name.erikkernan.easymode
```

Refresh the UDID if you replace the phone: `xcrun xctrace list devices`.

## Architecture Context
- **Main App**: SwiftUI/SwiftData app handling task management.
- **Extensions**:
  - `DeviceActivityMonitorExtension`: Re-applies shields and monitors activity.
  - `ShieldConfigurationExtension`: Customizes the "App Blocked" UI.
  - `ShieldActionExtension`: Handles button taps on the shield.
- **Shared**: `Shared/SharedStorage.swift` uses App Groups (`group.com.easymode.shared`) for cross-process communication.

## Apple Developer (identifiers & signing)

After bundle ID changes, register identifiers and capabilities in the Developer Portal using the exact IDs from the Xcode project:

```bash
./scripts/list-apple-bundle-ids.sh
```

Step-by-step checklist: [`docs/APPLE_DEVELOPER.md`](./docs/APPLE_DEVELOPER.md).

## Development Guidelines
- **SwiftLint**: Rules are defined in `.swiftlint.yml`.
- **SwiftFormat**: Configuration in `.swiftformat`.
- **Testing**: Use `Testing` framework for unit tests and `XCTest` for UI tests.
- **UX Issues**: Track all UX, UI, and brand issues in [`UX_ISSUES.md`](./UX_ISSUES.md). Review periodically, update statuses, and route accepted items to the roadmap.
- **Design assets**: When shipping UI/icon/brand work, include **all** related binaries in git (e.g. `Design/AppIcon/*`, asset catalog PNGs, and any **reference/source PNGs** at repo root used to build icons — even if not linked in Xcode — so history and handoff stay complete).
