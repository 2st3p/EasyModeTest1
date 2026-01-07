# EasyMode Comprehensive Improvements Implementation Plan

**Goal:** Ship a comprehensive set of organizational, performance, and code quality improvements (shared storage consistency, task lifecycle integrity, accurate blocking UI, and expanded tests).

**Architecture:** Keep SwiftUI + SwiftData + MVVM; centralize app-group storage in `SharedStorage`, persist Screen Time selection only on explicit user actions, make task lifecycle explicit (completed/cancelled timestamps), and add deterministic UI/testing hooks.

**Tech Stack:** SwiftUI, SwiftData, FamilyControls, ManagedSettings, DeviceActivity, Swift Testing, Xcode UI Tests.

**Constraint:** Do not change the app's design or user-facing functionality. All changes must preserve the current UI and behavior.

### Task 0: Baseline checks

**Files:**
- Modify: none

**Step 1: Review project structure**

Open `EasyModeTest1.xcodeproj` in Xcode and confirm the app target loads without errors.

### Task 1: Make SharedStorage testable and add unit tests

**Files:**
- Modify: `Shared/SharedStorage.swift`
- Create: `EasyModeTest1Tests/SharedStorageTests.swift`

**Step 1: Write the failing test**

```swift
import Testing
@testable import EasyModeTest1

struct SharedStorageTests {
    @Test @MainActor
    func currentTaskRoundTrip() throws {
        let suiteName = "SharedStorageTests.currentTask"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let storage = SharedStorage(defaults: defaults)
        storage.setCurrentTask("Draft spec")
        #expect(storage.getCurrentTask() == "Draft spec")
        storage.clearCurrentTask()
        #expect(storage.getCurrentTask() == nil)
    }

    @Test @MainActor
    func focusActiveRoundTrip() throws {
        let suiteName = "SharedStorageTests.focusActive"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let storage = SharedStorage(defaults: defaults)
        storage.setFocusActive(true)
        #expect(storage.isFocusActive() == true)
        #expect(storage.getFocusStartTime() != nil)
        storage.setFocusActive(false)
        #expect(storage.isFocusActive() == false)
        #expect(storage.getFocusStartTime() == nil)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1 -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1Tests/SharedStorageTests`
Expected: FAIL with "init is inaccessible due to 'private' protection level".

**Step 3: Write minimal implementation**

```swift
final class SharedStorage {
    static let shared = SharedStorage(defaults: SharedStorage.makeDefaults())

    private static func makeDefaults() -> UserDefaults {
        if let groupDefaults = UserDefaults(suiteName: Self.appGroupIdentifier) {
            return groupDefaults
        }
        print("App Group '\(Self.appGroupIdentifier)' not available. Using standard UserDefaults.")
        return .standard
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1 -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1Tests/SharedStorageTests`
Expected: TEST SUCCEEDED.

**Step 5: Validate tests remain green**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1 -destination 'platform=iOS Simulator,name=iPhone 15' test`
Expected: TEST SUCCEEDED.

### Task 2: Add SharedStorage to targets and centralize app-group usage

**Files:**
- Modify: `EasyModeTest1.xcodeproj/project.pbxproj` (via Xcode)
- Modify: `EasyModeTest1/Blocking/ScreenTimeManager.swift`
- Modify: `DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.swift`
- Modify: `ShieldConfigurationExtension/ShieldConfigurationExtension.swift`

**Step 1: Ensure SharedStorage is in all targets**

Open `EasyModeTest1.xcodeproj` in Xcode.
- Select `Shared/SharedStorage.swift` in the navigator.
- In the File Inspector, check Target Membership for:
  - `EasyModeTest1`
  - `DeviceActivityMonitorExtension`
  - `ShieldConfigurationExtension`
  - `ShieldActionExtension`
- If the file is missing from the project: File > Add Files to "EasyModeTest1"..., choose `Shared/SharedStorage.swift`, and check all four targets.

Verify from CLI:
Run: `rg -n "SharedStorage.swift" EasyModeTest1.xcodeproj/project.pbxproj`
Expected: >= 4 references (one per target build phase).

**Step 2: Run a baseline build**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1 -destination 'platform=iOS Simulator,name=iPhone 15' build`
Expected: BUILD SUCCEEDED.

**Step 3: Replace app-group storage in ScreenTimeManager**

```swift
// Remove selectionKey and appGroupIdentifier constants.

private func saveSelection() {
    #if canImport(FamilyControls)
    SharedStorage.shared.saveSelection(activitySelection)
    #endif
}

private func loadSavedSelection() {
    #if canImport(FamilyControls)
    activitySelection = SharedStorage.shared.loadSelection() ?? FamilyActivitySelection()
    #endif
}

private func saveCurrentTask(_ taskText: String) {
    SharedStorage.shared.setCurrentTask(taskText)
}

private func clearCurrentTask() {
    SharedStorage.shared.clearCurrentTask()
}

static func getCurrentTask() -> String? {
    SharedStorage.shared.getCurrentTask()
}
```

**Step 4: Replace app-group storage in extensions**

DeviceActivityMonitorExtension:

```swift
private func loadStoredSelection() -> FamilyActivitySelection? {
    SharedStorage.shared.loadSelection()
}
```

ShieldConfigurationExtension:

```swift
private func getCurrentTask() -> String? {
    SharedStorage.shared.getCurrentTask()
}
```

**Step 5: Run a build to verify**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1 -destination 'platform=iOS Simulator,name=iPhone 15' build`
Expected: BUILD SUCCEEDED.

**Step 6: Validate build remains green**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1 -destination 'platform=iOS Simulator,name=iPhone 15' build`
Expected: BUILD SUCCEEDED.

### Task 3: Persist Screen Time selection only on explicit actions (no UI changes)

**Files:**
- Modify: `EasyModeTest1/Blocking/ScreenTimeManager.swift`
- Modify: `EasyModeTest1/ViewModels/BlockViewModel.swift`
- Modify: `EasyModeTest1/Views/Onboarding/AppSelectionPageView.swift`
- Create: `EasyModeTest1Tests/BlockSelectionTests.swift`

**Decision:** Do not change any user-facing UI or behavior. Only adjust persistence timing internally.

**Step 1: Write the failing test**

```swift
import Testing
@testable import EasyModeTest1
import SwiftData

struct BlockSelectionTests {
    @Test @MainActor
    func saveMockSelectedApps_replacesPriorSelection() throws {
        let container = try ModelContainer(for: BlockedApp.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        let viewModel = BlockViewModel()

        context.insert(BlockedApp(bundleID: "com.apple.mail", appName: "Mail"))
        try context.save()

        let selection: Set<String> = ["com.apple.safari"]
        try viewModel.saveMockSelectedApps(selection, from: try context.fetch(FetchDescriptor<BlockedApp>()), using: context)

        let updated = try context.fetch(FetchDescriptor<BlockedApp>())
        #expect(updated.count == 1)
        #expect(updated.first?.bundleID == "com.apple.safari")
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1 -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1Tests/BlockSelectionTests`
Expected: FAIL because the test file does not exist yet.

**Step 3: Persist selection only on explicit save**

ScreenTimeManager: remove `didSet` persistence and add explicit method.

```swift
@Published var activitySelection = FamilyActivitySelection()

func persistSelection() {
    saveSelection()
}
```

BlockViewModel: call persist after saving changes (both real and mock).

```swift
if hasChanges {
    try modelContext.save()
    screenTimeManager.persistSelection()
}
```

AppSelectionPageView: persist before completing onboarding.

```swift
private func completeOnboarding() {
    HapticManager.shared.impact()
    #if canImport(FamilyControls)
    screenTimeManager.persistSelection()
    #endif
    onComplete()
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1 -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1Tests/BlockSelectionTests`
Expected: TEST SUCCEEDED.



### Task 4: Add task cancellation/completion timestamps and enforce lifecycle integrity

**Files:**
- Modify: `EasyModeTest1/Models/Item.swift`
- Modify: `EasyModeTest1/ViewModels/TaskViewModel.swift`
- Create: `EasyModeTest1Tests/TaskViewModelTests.swift`

**Note:** This changes the SwiftData schema. If migration fails on an existing simulator/device, delete the app or reset the simulator to rebuild the store.

**Step 1: Write the failing test**

```swift
import Testing
@testable import EasyModeTest1
import SwiftData

struct TaskViewModelTests {
    @Test @MainActor
    func cancel_setsCancelledFields() throws {
        let container = try ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        let viewModel = TaskViewModel()

        viewModel.taskInput = "Write plan"
        try viewModel.createTask(from: [], using: context)
        let task = try context.fetch(FetchDescriptor<Item>()).first!

        try viewModel.cancelTask(task, using: context)
        #expect(task.isCancelled == true)
        #expect(task.cancelledAt != nil)
    }

    @Test @MainActor
    func complete_setsCompletedFields() throws {
        let container = try ModelContainer(for: Item.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        let viewModel = TaskViewModel()

        viewModel.taskInput = "Finish review"
        try viewModel.createTask(from: [], using: context)
        let task = try context.fetch(FetchDescriptor<Item>()).first!

        try viewModel.completeTask(task, using: context)
        #expect(task.isCompleted == true)
        #expect(task.completedAt != nil)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1 -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1Tests/TaskViewModelTests`
Expected: FAIL because `isCancelled`/`completedAt` do not exist.

**Step 3: Write minimal implementation**

Item model additions:

```swift
var completedAt: Date?
var cancelledAt: Date?
var isCancelled: Bool

init(taskText: String = "", timestamp: Date = .now, isInProgress: Bool = false, isCompleted: Bool = false, isCancelled: Bool = false, completedAt: Date? = nil, cancelledAt: Date? = nil) {
    self.taskText = taskText
    self.timestamp = timestamp
    self.isInProgress = isInProgress
    self.isCompleted = isCompleted
    self.isCancelled = isCancelled
    self.completedAt = completedAt
    self.cancelledAt = cancelledAt
}
```

TaskViewModel lifecycle updates:

```swift
for task in activeTasks {
    task.isInProgress = false
    task.isCancelled = true
    task.cancelledAt = Date()
}

// completeTask
task.isInProgress = false
task.isCompleted = true
task.completedAt = Date()

// cancelTask
task.isInProgress = false
task.isCancelled = true
task.cancelledAt = Date()
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1 -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1Tests/TaskViewModelTests`
Expected: TEST SUCCEEDED.

**Step 5: Validate tests remain green**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1 -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1Tests/TaskViewModelTests`
Expected: TEST SUCCEEDED.

### Task 5: Add accessibility identifiers for UI tests

**Files:**
- Modify: `EasyModeTest1/Views/Task/Subviews/TaskEntryView.swift`
- Modify: `EasyModeTest1/Views/Task/Subviews/ActiveTaskView.swift`
- Modify: `EasyModeTest1/Views/AppTabView.swift`
- Modify: `EasyModeTest1/Views/Log/LogView.swift`

**Step 1: Write the failing test**

```swift
// UI test will fail to find identifiers until they are added.
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1UITests -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1UITests/EasyModeTest1UITests`
Expected: FAIL with "No matches found for identifier".

**Step 3: Write minimal implementation**

```swift
TextField("I want to...", text: $taskInput, axis: .vertical)
    .accessibilityIdentifier("task.input")

Button("Start Focus") { ... }
    .accessibilityIdentifier("task.start")

Button(action: handleComplete) { ... }
    .accessibilityIdentifier("task.complete")

TabView { ... }
    .accessibilityIdentifier("tabs.root")

Text("History")
    .accessibilityIdentifier("log.title")
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1UITests -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1UITests/EasyModeTest1UITests`
Expected: TEST SUCCEEDED.

**Step 5: Validate UI tests see identifiers**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1UITests -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1UITests/EasyModeTest1UITests`
Expected: TEST SUCCEEDED.

### Task 6: Add deterministic UI test for onboarding + focus flow

**Files:**
- Modify: `EasyModeTest1/EasyModeTest1App.swift`
- Modify: `EasyModeTest1/Views/Onboarding/PermissionsPageView.swift`
- Modify: `EasyModeTest1UITests/EasyModeTest1UITests.swift`

**Step 1: Write the failing test**

```swift
import XCTest

final class EasyModeTest1UITests: XCTestCase {
    func testOnboardingToFirstTaskCompletion() {
        let app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launch()

        app.buttons["Get Started"].tap()
        app.buttons["Grant Permission"].tap()
        app.buttons["Skip for Now"].tap()

        let input = app.textFields["task.input"].firstMatch
        if !input.exists {
            let fallback = app.textViews["task.input"].firstMatch
            XCTAssertTrue(fallback.waitForExistence(timeout: 2))
            fallback.tap()
            fallback.typeText("Write spec")
        } else {
            XCTAssertTrue(input.waitForExistence(timeout: 2))
            input.tap()
            input.typeText("Write spec")
        }

        app.buttons["task.start"].tap()
        app.buttons["task.complete"].tap()

        app.tabBars.buttons["Log"].tap()
        XCTAssertTrue(app.staticTexts["log.title"].waitForExistence(timeout: 2))
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1UITests -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1UITests/EasyModeTest1UITests/testOnboardingToFirstTaskCompletion`
Expected: FAIL until onboarding is deterministic and identifiers are present.

**Step 3: Make onboarding deterministic for UI tests**

EasyModeTest1App: reset onboarding state when `-ui-testing` is passed.

```swift
init() {
    if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
}
```

PermissionsPageView: bypass the simulator delay when UI testing.

```swift
#if targetEnvironment(simulator)
if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
    isRequesting = false
    onContinue()
    return
}
#endif
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1UITests -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1UITests/EasyModeTest1UITests/testOnboardingToFirstTaskCompletion`
Expected: TEST SUCCEEDED.

**Step 5: Validate UI test passes**

Run: `xcodebuild -project EasyModeTest1.xcodeproj -scheme EasyModeTest1UITests -destination 'platform=iOS Simulator,name=iPhone 15' test -only-testing:EasyModeTest1UITests/EasyModeTest1UITests/testOnboardingToFirstTaskCompletion`
Expected: TEST SUCCEEDED.

### Task 7: Repo hygiene cleanup (optional)

**Files:**
- Delete: `DerivedData/`
- Delete: `.DS_Store`

**Step 1: Confirm deletion with user**

Ask: "Confirm removing DerivedData/ and .DS_Store from the project directory?".

**Step 2: Remove artifacts**

Run: `rm -rf DerivedData .DS_Store`
Expected: Files removed from the workspace.
