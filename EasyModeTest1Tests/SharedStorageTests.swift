import Foundation
import Testing
@testable import EasyModeTest1

struct SharedStorageTests {
    @Test
    func shieldContentBuilder_usesAppNameAndTaskWhenPresent() {
        let content = ShieldContentBuilder.build(
            currentTask: "Ship the blocking screen",
            blockedAppName: "Instagram",
            context: .application
        )

        #expect(content.title == "Ship the blocking screen")
        #expect(content.subtitle == "Instagram can wait until your session is done.")
        #expect(content.primaryButtonLabel == "Back to focus")
    }

    @Test
    func shieldContentBuilder_fallsBackWhenTaskMissing() {
        let content = ShieldContentBuilder.build(
            currentTask: "   ",
            blockedAppName: "TikTok",
            context: .application
        )

        #expect(content.title == "Stay focused")
        #expect(content.subtitle == "TikTok can wait until your session is done.")
    }

    @Test
    func shieldContentBuilder_usesGenericCopyWithoutAppName() {
        let content = ShieldContentBuilder.build(
            currentTask: "Write the spec",
            blockedAppName: nil,
            context: .webDomain
        )

        #expect(content.title == "Write the spec")
        #expect(content.subtitle == "This can wait until your session is done.")
    }

    @Test
    func shieldContentBuilder_fallsBackWhenEverythingMissing() {
        let content = ShieldContentBuilder.build(
            currentTask: nil,
            blockedAppName: nil,
            context: .category
        )

        #expect(content.title == "Stay focused")
        #expect(content.subtitle == "This can wait until your session is done.")
    }

    @Test
    func shieldContentBuilder_trimsLongTaskInput() {
        let longTask = "  Finish the custom blocking screen before touching anything else in this release.  "
        let content = ShieldContentBuilder.build(
            currentTask: longTask,
            blockedAppName: "YouTube",
            context: .application
        )

        #expect(content.title == "Finish the custom blocking screen before touching anything else in this release.")
        #expect(!content.title.isEmpty)
    }

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
        let startTime = Date(timeIntervalSince1970: 1_700_000_000)

        storage.setFocusActive(true, startTime: startTime)
        #expect(storage.isFocusActive() == true)
        #expect(storage.getFocusStartTime() == startTime)
        storage.setFocusActive(false)
        #expect(storage.isFocusActive() == false)
        #expect(storage.getFocusStartTime() == nil)
    }

    @Test @MainActor
    func mergeOnboardingCompletion_copiesFromStandardIntoSuite() throws {
        let suiteName = "SharedStorageTests.mergeOnboarding"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let hadStandardKey = UserDefaults.standard.object(forKey: "hasCompletedOnboarding") != nil
        let priorStandardValue = hadStandardKey ? UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") : false
        defer {
            if hadStandardKey {
                UserDefaults.standard.set(priorStandardValue, forKey: "hasCompletedOnboarding")
            } else {
                UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            }
        }

        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        let storage = SharedStorage(defaults: defaults)
        storage.mergeOnboardingCompletionFromAllStores()

        #expect(storage.hasCompletedOnboarding())
    }

    @Test @MainActor
    func clearAll_removesAllSessionKeys() throws {
        let suiteName = "SharedStorageTests.clearAll"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let storage = SharedStorage(defaults: defaults)
        storage.setCurrentTask("Draft spec")
        storage.setFocusActive(true, startTime: Date(timeIntervalSince1970: 1_700_000_001))

        storage.clearAll()

        #expect(storage.getCurrentTask() == nil)
        #expect(storage.isFocusActive() == false)
        #expect(storage.getFocusStartTime() == nil)
    }
}
