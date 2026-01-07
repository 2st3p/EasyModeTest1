EasyModeTest1

A SwiftUI iOS app to help you focus on one task at a time. Built with SwiftData and modern SwiftUI navigation.

Features
- Single-task focus flow with confetti celebration
- SwiftData persistence for tasks and blocked apps
- Block tab with optional System App Picker (FamilyControls) when available
- Log tab listing completed tasks with delete and clear-all

Requirements
- iOS 17+
- Xcode 15+

Getting Started
1. Open `EasyModeTest1.xcodeproj` in Xcode
2. Select the `EasyModeTest1` target and run on a simulator or device

Notes
- The `Block` tab uses a placeholder picker when `FamilyControls` is unavailable. On devices with Screen Time entitlements and FamilyControls, the System App Picker is used.
- Only one active task is allowed at a time.

Development
- Navigation uses `NavigationStack`
- Data models are defined with `@Model` in SwiftData

Roadmap
- Focus timer
- Rich analytics in Log
- Deeper Screen Time integrations

