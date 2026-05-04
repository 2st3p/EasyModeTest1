> **ARCHIVED — 2026-04-18.** Superseded by `Easymode/ROADMAP.md` (phases, open work) and the live codebase (source-of-truth for current behavior). Kept for historical reference only. Do not update.

# Easymode Feature Spec (Archived snapshot)

## Overview
- Single-task focus app with optional Screen Time blocking and a completion history log.
- Built with SwiftUI, SwiftData, and MVVM-style view models.

## Platforms and Requirements
- iOS 17+ (SwiftData usage).
- Xcode 15+.

## App Structure
- First launch shows onboarding; completion stored in AppStorage (`hasCompletedOnboarding`).
- Main UI is a TabView with three tabs: Home, Log, Settings.

## Onboarding Flow
- Welcome page with value proposition and "Get Started" CTA.
- Permissions page that requests Screen Time authorization and explains privacy.
  - Simulator path auto-advances without real permission prompts.
- App selection page:
  - FamilyActivityPicker on supported devices.
  - Simulator fallback list.
  - Button text changes based on whether apps are selected.

## Home (Task) Flow
- Idle state:
  - Prompt "What do you want to accomplish next?"
  - Single-line text input with 90 character max and auto-focus.
  - "Start Focus" button appears when input is non-empty.
- Focus mode:
  - Displays active task text.
  - "Complete" action triggers a ripple animation and haptics.
  - "Give Up" shows confirmation and ends the session.
- Only one active task at a time (enforced in the view model).

## Blocking and Screen Time
- ScreenTimeManager handles:
  - Authorization via FamilyControls.
  - Persisting app selections in shared UserDefaults (App Group).
  - Starting focus sessions by applying ManagedSettings shields.
  - Scheduling DeviceActivity monitoring for persistence.
  - Ending focus sessions by removing shields and clearing current task.
- DeviceActivityMonitorExtension:
  - Re-applies shields at interval start or warning.
- ShieldConfigurationExtension:
  - Custom shield UI with "Focus Mode Active" title and current task subtitle.
- ShieldActionExtension:
  - Primary button closes the shield (strict blocking, no overrides).

## Settings (Blocked Apps)
- "Strict Blocking" info card.
- Static list of common apps with selectable toggles (stored as BlockedApp entries).
- "Add more apps" sheet:
  - FamilyActivityPicker on device when authorized.
  - Mock list on simulator or non-FamilyControls platforms.

## Log (History)
- Displays completed tasks in reverse chronological order.
- Shows relative time since task creation.
- Empty state quote when no completed tasks exist.

## Data Models
- Item:
  - taskText, timestamp, isInProgress, isCompleted.
- BlockedApp:
  - bundleID, appName, lastModified.

## UI Theme and Interaction
- Parchment color theme, custom font helpers, and shadow modifiers.
- Haptic feedback for typing, actions, and completion.
