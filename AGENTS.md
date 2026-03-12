# AGENTS.md

## Project Overview
EasyMode is a focused iOS application that helps users concentrate on a single task by blocking distracting apps using Apple's Screen Time (FamilyControls) API.

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

## Architecture Context
- **Main App**: SwiftUI/SwiftData app handling task management.
- **Extensions**:
  - `DeviceActivityMonitorExtension`: Re-applies shields and monitors activity.
  - `ShieldConfigurationExtension`: Customizes the "App Blocked" UI.
  - `ShieldActionExtension`: Handles button taps on the shield.
- **Shared**: `Shared/SharedStorage.swift` uses App Groups (`group.com.easymode.shared`) for cross-process communication.

## Development Guidelines
- **SwiftLint**: Rules are defined in `.swiftlint.yml`.
- **SwiftFormat**: Configuration in `.swiftformat`.
- **Testing**: Use `Testing` framework for unit tests and `XCTest` for UI tests.
