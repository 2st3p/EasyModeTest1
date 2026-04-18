# App Blocking Engine Setup Guide

This guide covers how to set up the Screen Time-based app blocking engine for EasyMode.

## Overview

The blocking engine uses these Apple frameworks and targets:
- **FamilyControls**: Authorization and app/category selection
- **ManagedSettings**: Applying shields (blocks) to selected apps
- **DeviceActivity**: Scheduling and persisting blocking across app termination
- **ActivityKit** (via **`EasyModeLiveActivity`** widget extension): Lock Screen Live Activity for the current focus task

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Main App                                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ TaskViewModel   │  │ BlockViewModel  │  │ScreenTimeManager│ │
│  │ (starts/stops   │→ │ (app selection) │→ │ (coordinates    │ │
│  │  focus)         │  │                 │  │  everything)    │ │
│  └─────────────────┘  └─────────────────┘  └────────┬────────┘ │
└───────────────────────────────────────────────────────┼─────────┘
                                                        │
                        App Group (Shared UserDefaults) │
                                                        ▼
┌─────────────────────┐ ┌─────────────────────┐ ┌─────────────────────┐
│ DeviceActivity      │ │ ShieldConfiguration │ │ ShieldAction        │
│ Monitor Extension   │ │ Extension           │ │ Extension           │
│ (background         │ │ (customizes         │ │ (handles button     │
│  persistence)       │ │  blocked UI)        │ │  taps)              │
└─────────────────────┘ └─────────────────────┘ └─────────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │ EasyModeLiveActivity│
                    │ (Lock Screen task)  │
                    └─────────────────────┘
```

## Step 1: Apple Developer Setup

### 1.1 Enable Screen Time API
1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles** → **Identifiers**
3. Select your App ID (or create one)
4. Enable **Family Controls** capability
5. Click Save

### 1.2 Create App Group
1. In the Developer Portal, go to **Identifiers** → **App Groups**
2. Click **+** to create a new App Group
3. Enter: `group.com.easymode.shared` (or your preferred identifier)
4. Click Continue → Register

## Step 2: Xcode Project Configuration

### 2.1 Main App Capabilities
1. Open your project in Xcode
2. Select the **EasyModeTest1** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability** and add:
   - **Family Controls**
   - **App Groups** (select `group.com.easymode.shared`)

### 2.2 Family Controls usage string (Info.plist)
This repo’s main target uses **Generate Info Plist** (`GENERATE_INFOPLIST_FILE = YES`) and sets the string in **Build Settings** as `INFOPLIST_KEY_NSFamilyControlsUsageDescription`. If you edit `Info.plist` manually instead, add the equivalent key:

```xml
<key>NSFamilyControlsUsageDescription</key>
<string>EasyMode needs access to Screen Time to block distracting apps during your focus sessions.</string>
```

Enable **Live Activities** on the main app target (`NSSupportsLiveActivities` / `INFOPLIST_KEY_NSSupportsLiveActivities`) so the `EasyModeLiveActivity` extension can run.

## Step 3: Create Extension Targets

### 3.1 Device Activity Monitor Extension
1. In Xcode: **File** → **New** → **Target**
2. Search for **Device Activity Monitor Extension**
3. Name it: `DeviceActivityMonitorExtension`
4. Click Finish
5. **Delete** the auto-generated Swift file
6. **Add** `DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.swift` to this target
7. Add capabilities:
   - **Family Controls**
   - **App Groups** (same group as main app)

### 3.2 Shield Configuration Extension
1. **File** → **New** → **Target**
2. Search for **Shield Configuration Extension**
3. Name it: `ShieldConfigurationExtension`
4. Click Finish
5. **Delete** the auto-generated Swift file
6. **Add** `ShieldConfigurationExtension/ShieldConfigurationExtension.swift` to this target
7. Add capabilities:
   - **Family Controls**
   - **App Groups** (same group)

### 3.3 Shield Action Extension
1. **File** → **New** → **Target**
2. Search for **Shield Action Extension**
3. Name it: `ShieldActionExtension`
4. Click Finish
5. **Delete** the auto-generated Swift file
6. **Add** `ShieldActionExtension/ShieldActionExtension.swift` to this target
7. Add capabilities:
   - **Family Controls**
   - **App Groups** (same group)

### 3.4 Live Activity / Widget Extension (`EasyModeLiveActivity`)
1. **File** → **New** → **Target** → **Widget Extension** (or the template Xcode offers for Live Activities for your SDK version).
2. Name it: `EasyModeLiveActivity` (must match the existing folder / bundle in this repo).
3. Wire the Swift sources under `EasyModeLiveActivity/` to this target.
4. Add **App Groups** (same `group.com.easymode.shared` as the main app) if the widget reads shared state.
5. Ensure the main app target has Live Activities enabled (see §2.2).

### 3.5 Add Shared Files to Extensions
Add these files to **all extension targets** that read cross-process state:
- `Shared/SharedStorage.swift`

## Step 4: Update App Group Identifier

If you used a different App Group identifier, update it in these files:
- `EasyModeTest1/Blocking/ScreenTimeManager.swift` → `appGroupIdentifier`
- `Shared/SharedStorage.swift` → `appGroupIdentifier`
- `DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.swift` → `appGroupIdentifier`
- `ShieldConfigurationExtension/ShieldConfigurationExtension.swift` → `appGroupIdentifier`

## Step 5: Build & Test

### 5.1 Build Order
Build targets in this order:
1. Main app (EasyModeTest1)
2. DeviceActivityMonitorExtension
3. ShieldConfigurationExtension
4. ShieldActionExtension
5. EasyModeLiveActivity

### 5.2 Testing on Device
**Important**: Screen Time APIs only work on physical devices, not the Simulator.

1. Connect your iPhone
2. Build and run on device
3. Grant Screen Time permission when prompted
4. Select apps to block in the Block tab (the tab bar may still label it **Settings** in some builds)
5. Start a focus session
6. Try to open a blocked app - you should see the shield

### 5.3 Debug Tips
- Use **Console.app** on Mac to view extension logs
- Filter by process name: `DeviceActivityMonitorExtension`
- Extensions run in separate processes, so breakpoints in the main app won't hit extension code

## Troubleshooting

### "Authorization Failed"
- Ensure Family Controls capability is enabled in Developer Portal
- Check that the Family Controls usage string is present (build setting `INFOPLIST_KEY_NSFamilyControlsUsageDescription` or `Info.plist`)
- Verify signing with a valid provisioning profile

### "Shields Not Appearing"
- Confirm extensions are built and installed
- Check App Group identifier matches across all targets
- Verify `FamilyActivitySelection` is being saved correctly

### "Blocking Doesn't Persist After App Kill"
- Ensure DeviceActivityMonitor extension is properly configured
- Check that `DeviceActivityCenter.startMonitoring()` is called
- Verify extension has necessary entitlements

## File Structure

```
EasyModeTest1/
├── EasyModeTest1/
│   ├── Blocking/
│   │   └── ScreenTimeManager.swift    ← Core blocking logic
│   ├── ViewModels/
│   │   ├── BlockViewModel.swift       ← Updated with integration
│   │   └── TaskViewModel.swift        ← Updated with focus blocking
│   └── ...
├── Shared/
│   └── SharedStorage.swift            ← Cross-process communication
├── DeviceActivityMonitorExtension/
│   └── DeviceActivityMonitorExtension.swift
├── ShieldConfigurationExtension/
│   └── ShieldConfigurationExtension.swift
├── ShieldActionExtension/
│   └── ShieldActionExtension.swift
└── EasyModeLiveActivity/
    └── (Live Activity widget sources)
```

## Privacy Policy Requirement

Apple requires a privacy policy for apps using FamilyControls. Your policy should explain:
- What data you collect (app selections, focus history)
- How the data is used (locally for blocking, not transmitted)
- How users can delete their data (clear settings, delete app)

## Next steps

Product direction, phased work, and UX backlog live in **`EasyModeTest1/ROADMAP.md`** (blocking engine items, App Store checklist, scheduled focus, pause/resume, and more). Use that file instead of duplicating a roadmap here.
