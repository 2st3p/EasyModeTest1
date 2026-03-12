import Foundation
import SwiftData

@MainActor
enum LaunchStateCoordinator {
    static func prepareForLaunch(
        modelContext: ModelContext,
        isUITesting: Bool,
        sharedStorage: SharedStorage = .shared
    ) throws {
        if isUITesting {
            try resetPersistentStateForUITesting(modelContext: modelContext, sharedStorage: sharedStorage)
        }

        try reconcileFocusSession(modelContext: modelContext, sharedStorage: sharedStorage)
    }

    static func reconcileFocusSession(
        modelContext: ModelContext,
        sharedStorage: SharedStorage = .shared
    ) throws {
        let descriptor = FetchDescriptor<Item>(predicate: #Predicate<Item> { item in
            item.isInProgress
        })
        let activeTasks = try modelContext.fetch(descriptor)

        guard let activeTask = activeTasks.first else {
            sharedStorage.clearCurrentTask()
            sharedStorage.setFocusActive(false)
            return
        }

        sharedStorage.setCurrentTask(activeTask.taskText)

        if !sharedStorage.isFocusActive() || sharedStorage.getFocusStartTime() == nil {
            sharedStorage.setFocusActive(true, startTime: activeTask.timestamp)
        }
    }

    private static func resetPersistentStateForUITesting(
        modelContext: ModelContext,
        sharedStorage: SharedStorage
    ) throws {
        for item in try modelContext.fetch(FetchDescriptor<Item>()) {
            modelContext.delete(item)
        }

        for blockedApp in try modelContext.fetch(FetchDescriptor<BlockedApp>()) {
            modelContext.delete(blockedApp)
        }

        try modelContext.save()
        sharedStorage.clearAll()
    }
}
