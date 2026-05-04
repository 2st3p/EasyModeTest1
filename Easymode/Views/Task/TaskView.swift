//
//  TaskView.swift
//  Easymode
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData
import UIKit

/// The main task management view that displays and manages user tasks.
/// This view serves as the primary interface for task creation, viewing, and completion.
/// It conditionally displays either the task entry interface or the active task view
/// based on whether there is an active task in progress.
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
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
        .alert("No Apps Selected", isPresented: $viewModel.showNoAppsWarning) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your task is active, but no apps are blocked. Select apps in the Settings tab to enable blocking.")
        }
        .onAppear {
            // Restore draft input on appear (survives tab switches)
            if viewModel.taskInput.isEmpty && !activeTasks.isEmpty == false {
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
    
    /// Completes the given task by marking it as completed
    private func completeTask(_ task: Item) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
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
