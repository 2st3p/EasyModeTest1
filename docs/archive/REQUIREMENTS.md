> **ARCHIVED — 2026-04-18.** Early engineering requirements doc. Superseded by current code + `Easymode/ROADMAP.md`. Note: §4 "Scope: Storage only for V1" is **no longer true** — blocking via `DeviceActivity` + `ManagedSettings` is implemented. Kept for historical reference; do not update.

# EasyMode Engineering Requirements & Specifications

## 1. Core Architecture & Tech Stack
- **Framework**: SwiftUI (Target: iOS 16+ for `NavigationStack`)
- **Persistence**: SwiftData (Core Data replacement)
- **Architecture Pattern**: MVVM (Model-View-ViewModel)
- **Concurrency**: Swift Concurrency (`async`/`await`)

## 2. Data Models (Schema)

### Task Entity (`Item`)
- `id`: UUID/PersistentIdentifier
- `text`: String
- `createdAt`: Date
- `completedAt`: Date?
- `status`: Enum (pending, inProgress, completed, cancelled)
*Constraint: Maximum 1 task 'inProgress' at a time.*

### Blocked App Entity (`BlockedApp`)
- `bundleID`: String
- `displayName`: String
- `selectionDate`: Date

## 3. Feature: Task Management (The Core Loop)
**Priority: Critical**

### A. Task Entry (Idle State)
- **Input**: Standard SwiftUI `TextField`.
- **Validation**: Prevent empty submissions.
- **Action**: "Lock In" button transitions app to **Active State**.

### B. Active Task Mode (Focus State)
- **Display**: Prominent task text.
- **Action**: "Complete" button.
- **System Response**:
  1. Haptic feedback (`.success`).
  2. Simple success animation (using `Canvas` or Swift package).
  3. Mark as completed.
  4. Return to idle state.
- **Cancellation**: "Cancel" button -> Mark cancelled -> Return to idle.

## 4. Feature: App Blocking (Focus Mode)
**Priority: High**

- **Framework**: `FamilyControls` (Screen Time API).
- **Authorization**: Request on first launch.
- **UI**:
  - Use system `FamilyActivityPicker` (requires `.shielded` entitlement capability).
  - Fallback: Simple mock list for Simulator development.
- **Scope**: **Storage only** for V1. (Logic to actually block apps via `DeviceActivity` is out of scope for initial build).

## 5. Feature: History (Log)
**Priority: Medium**

- **View**: Standard SwiftUI `List`.
- **Data**: `Item`s where status is completed.
- **Actions**: Delete items (swipe), Clear All.

## 6. Design Guidelines (Foundation)
**Goal**: Clean, standard SwiftUI with warm aesthetics. Avoid custom renderers or complex layout engines.

### A. Visual Language
- **Style**: "Clean & Warm". Use standard system components styled with custom colors/fonts, rather than rebuilding components from scratch.
- **Typography**: System font (`.rounded` design).
- **Colors**:
  - Background: Off-white (`Color(uiColor: .systemGroupedBackground)` or similar).
  - Accents: Soft Blue, Sage Green, Warm Orange.
- **Materials**: Use standard `.regularMaterial` or `.ultraThinMaterial` for backgrounds/cards.

### B. Specific Components
- **Buttons**: Standard `Button` with `.borderedProminent` style, customized with `tint` and `cornerRadius`.
- **Navigation**: Standard `TabView` (bottom bar). *Avoid custom floating tab bars for V1.*
- **Cards**: `VStack` with `.background(Material)` and `.cornerRadius`.

## 7. Constraints
- **Single Active Task**: Logic must enforce 0 or 1 active task.
- **Error Handling**: Show user-facing alerts for errors (no crashes).
