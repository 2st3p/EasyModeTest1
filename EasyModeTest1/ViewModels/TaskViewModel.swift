//
//  TaskViewModel.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import Foundation
import SwiftData

/// ViewModel for managing task-related operations
/// Handles task creation, completion, cancellation, and enforces the single active task constraint
/// Now integrates with ScreenTimeManager to block apps during focus sessions
@MainActor
final class TaskViewModel: ObservableObject {
    /// The current text input for a new task
    @Published var taskInput: String = ""
    
    /// Error message to display to the user
    @Published var errorMessage: String?
    
    /// Whether an error alert should be shown
    @Published var showError: Bool = false
    
    /// Reference to the shared ScreenTimeManager
    private let screenTimeManager = ScreenTimeManager.shared
    
    init() {}
    
    /// Creates a new task with the provided text and marks it as in progress
    /// Enforces the constraint that only one task can be in progress at a time
    /// Starts app blocking when task begins
    func createTask(from activeTasks: [Item], using modelContext: ModelContext) throws {
        let trimmedInput = taskInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else {
            throw TaskError.emptyInput
        }
        
        // Ensure only one active task at a time
        for task in activeTasks {
            task.isInProgress = false
            task.isCancelled = true
            task.cancelledAt = Date()
        }
        
        // Create and save the new task
        let newTask = Item(
            taskText: trimmedInput,
            timestamp: Date(),
            isInProgress: true,
            isCompleted: false
        )
        modelContext.insert(newTask)
        
        do {
            try modelContext.save()
            
            // Start app blocking for focus session
            startFocusBlocking(taskText: trimmedInput)
            
            taskInput = ""
        } catch {
            throw TaskError.saveFailed(error.localizedDescription)
        }
    }
    
    /// Completes the given task by marking it as completed and removing it from in-progress status
    /// Ends app blocking when task completes
    func completeTask(_ task: Item, using modelContext: ModelContext) throws {
        task.isInProgress = false
        task.isCompleted = true
        task.isCancelled = false
        task.completedAt = Date()
        
        do {
            try modelContext.save()
            
            // End app blocking
            endFocusBlocking()
        } catch {
            throw TaskError.saveFailed(error.localizedDescription)
        }
    }
    
    /// Cancels the given task by removing it from in-progress status
    /// Ends app blocking when task is cancelled
    func cancelTask(_ task: Item, using modelContext: ModelContext) throws {
        task.isInProgress = false
        task.isCancelled = true
        task.cancelledAt = Date()
        
        do {
            try modelContext.save()
            
            // End app blocking
            endFocusBlocking()
        } catch {
            throw TaskError.saveFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Focus Blocking
    
    /// Starts blocking selected apps for the focus session
    private func startFocusBlocking(taskText: String) {
        // Only block if there are apps selected
        guard screenTimeManager.hasSelectedApps else { return }
        
        do {
            try screenTimeManager.startFocusSession(taskText: taskText)
        } catch {
            // Log error but don't fail the task creation
            // User can still focus even if blocking fails
            print("⚠️ Failed to start app blocking: \(error.localizedDescription)")
            
            // Optionally show a non-blocking warning
            if let screenTimeError = error as? ScreenTimeError {
                errorMessage = "Blocking unavailable: \(screenTimeError.localizedDescription)"
                showError = true
            }
        }
    }
    
    /// Ends blocking for all apps
    private func endFocusBlocking() {
        screenTimeManager.endFocusSession()
    }
    
    // MARK: - Error Handling
    
    /// Handles errors by setting the error message and showing the alert
    func handleError(_ error: Error) {
        if let taskError = error as? TaskError {
            errorMessage = taskError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
    }
}

/// Errors that can occur during task operations
enum TaskError: LocalizedError {
    case emptyInput
    case saveFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "Task text cannot be empty"
        case .saveFailed(let message):
            return "Failed to save task: \(message)"
        }
    }
}
