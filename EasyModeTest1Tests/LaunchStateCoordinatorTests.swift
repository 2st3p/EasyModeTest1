import Foundation
import SwiftData
import Testing
@testable import EasyModeTest1

struct LaunchStateCoordinatorTests {
    @Test @MainActor
    func reconcileFocusSession_rehydratesSharedStateFromActiveTask() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let defaults = try makeDefaults(suiteName: "LaunchStateCoordinatorTests.rehydrate")
        let storage = SharedStorage(defaults: defaults)
        let startTime = Date(timeIntervalSince1970: 1_725_000_000)

        context.insert(
            Item(
                taskText: "Restore focus",
                timestamp: startTime,
                isInProgress: true,
                isCompleted: false
            )
        )
        try context.save()

        try LaunchStateCoordinator.reconcileFocusSession(modelContext: context, sharedStorage: storage)

        #expect(storage.getCurrentTask() == "Restore focus")
        #expect(storage.isFocusActive() == true)
        #expect(storage.getFocusStartTime() == startTime)
    }

    @Test @MainActor
    func reconcileFocusSession_clearsStaleSharedStateWithoutActiveTask() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let defaults = try makeDefaults(suiteName: "LaunchStateCoordinatorTests.clear")
        let storage = SharedStorage(defaults: defaults)

        storage.setCurrentTask("Stale task")
        storage.setFocusActive(true, startTime: Date(timeIntervalSince1970: 1_600_000_000))

        try LaunchStateCoordinator.reconcileFocusSession(modelContext: context, sharedStorage: storage)

        #expect(storage.getCurrentTask() == nil)
        #expect(storage.isFocusActive() == false)
        #expect(storage.getFocusStartTime() == nil)
    }

    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: Item.self,
            BlockedApp.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    private func makeDefaults(suiteName: String) throws -> UserDefaults {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            throw TestSupportError.failedToCreateDefaults
        }

        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}

private enum TestSupportError: Error {
    case failedToCreateDefaults
}
