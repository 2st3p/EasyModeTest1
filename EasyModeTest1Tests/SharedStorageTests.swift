import Foundation
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
