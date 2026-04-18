EasyModeTest1

A SwiftUI iOS app to help you focus on one task at a time. Built with SwiftData and modern SwiftUI navigation.

Features
- Single-task focus flow with completion feedback (haptics, sound, and in-app completion visuals)
- SwiftData persistence for focus tasks; Screen Time selections persisted via App Group shared storage
- Block tab with optional System App Picker (`FamilyControls`) when available; simulator fallback when not
- Live Activities showing the current focus task on the Lock Screen
- Log tab listing completed tasks in reverse chronological order (delete / clear-all UI is on the roadmap)

Requirements
- iOS **17.6+** (main app deployment target in the Xcode project)
- Xcode **16+** (CI selects Xcode 16; older Xcode may not match the project file)

Getting Started
1. Open `EasyModeTest1.xcodeproj` in Xcode
2. Select the `EasyModeTest1` target and run on a simulator or device

Testing
- `./scripts/test.sh build` builds the app on an available iPhone simulator.
- `./scripts/test.sh unit` runs the fast unit/service test lane.
- `./scripts/test.sh ui` runs the lean UI regression lane.
- `./scripts/test.sh all` runs the default pre-merge gate.
- `./scripts/test.sh perf-ui` runs the opt-in launch performance test.

Notes
- The Block tab uses a placeholder picker when `FamilyControls` is unavailable. On devices with Screen Time entitlements and FamilyControls, the System App Picker is used.
- Only one active task is allowed at a time.

Development
- Navigation uses `NavigationStack`
- Data models are defined with `@Model` in SwiftData

Roadmap
- See [`EasyModeTest1/ROADMAP.md`](EasyModeTest1/ROADMAP.md) for phases, UX backlog, and upcoming work (scheduled focus, task pause/resume, App Store checklist).
