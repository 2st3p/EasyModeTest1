//
//  TaskView.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData

/// Top-level Home view. Swaps between task entry and the active task view based on SwiftData state.
struct TaskView: View {
    /// Provides access to the SwiftData model context for data operations
    @Environment(\.modelContext) private var modelContext
    /// Fetches active tasks from the data store
    @Query(filter: #Predicate<Item> { $0.isInProgress }) private var activeTasks: [Item]
    /// ViewModel for task operations
    @StateObject private var viewModel = TaskViewModel()
    /// Persisted draft input to survive tab switches
    @AppStorage("draftTaskInput") private var draftTaskInput: String = ""

    var body: some View {
        ZStack {
            if let activeTask = activeTasks.first {
                // Show active task view when a task is in progress
                ActiveTaskView(
                    task: activeTask,
                    onComplete: { completeTask(activeTask) },
                    onCancel: { cancelTask(activeTask) }
                )
                .transition(.opacity)
                .zIndex(50)
            } else {
                // Show task entry view when no task is in progress
                TaskEntryView(
                    taskInput: $viewModel.taskInput,
                    onSubmit: { createTask() }
                )
                .transition(.opacity)
            }
        }
        .parchmentBackground()
        .animation(.easeInOut(duration: 0.6), value: activeTasks.first?.persistentModelID)
        .alert(String(localized: "alert.error.title"), isPresented: $viewModel.showError) {
            Button(String(localized: "alert.ok"), role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .alert(String(localized: "task.no_apps.alert.title"), isPresented: $viewModel.showNoAppsWarning) {
            Button(String(localized: "alert.ok"), role: .cancel) { }
        } message: {
            Text(String(localized: "task.no_apps.alert.message"))
        }
        .onDisappear {
            viewModel.cancelPendingLiveActivityWork()
        }
        .onAppear {
            // Restore draft input on appear (survives tab switches).
            // Only when there is no active task — otherwise the draft would shadow it.
            if viewModel.taskInput.isEmpty && activeTasks.isEmpty {
                viewModel.taskInput = draftTaskInput
            }
        }
        .onChange(of: viewModel.taskInput) { _, newValue in
            // Save draft input for tab switch recovery
            draftTaskInput = newValue
        }
    }
    
    /// Creates a new task with the provided text and marks it as in progress
    private func createTask() {
        do {
            try viewModel.createTask(from: activeTasks, using: modelContext)
            // Clear draft after successful task creation
            draftTaskInput = ""
        } catch {
            viewModel.handleError(error)
        }
    }
    
    /// Completes the given task by marking it as completed.
    /// Success haptic is owned by `ActiveTaskView.handleComplete` so we don't double-fire.
    private func completeTask(_ task: Item) {
        do {
            try viewModel.completeTask(task, using: modelContext)
        } catch {
            viewModel.handleError(error)
        }
    }
    
    /// Cancels the given task by removing it from in-progress status
    private func cancelTask(_ task: Item) {
        do {
            try viewModel.cancelTask(task, using: modelContext)
        } catch {
            viewModel.handleError(error)
        }
    }
}

#Preview {
    TaskView()
        .modelContainer(for: Item.self, inMemory: true)
}
