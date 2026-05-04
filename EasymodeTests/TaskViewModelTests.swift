import Testing
@testable import Easymode
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
