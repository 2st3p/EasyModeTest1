//
//  LogViewModel.swift
//  Easymode
//
//  Created by Erik Kernan on 3/25/25.
//

import Foundation
import SwiftData

/// ViewModel for managing task history/log operations
/// Handles deletion and clearing of completed tasks
@MainActor
final class LogViewModel: ObservableObject {
    /// Error message to display to the user
    @Published var errorMessage: String?
    
    /// Whether an error alert should be shown
    @Published var showError: Bool = false
    
    init() {}
    
    /// Deletes tasks at the specified indices
    func deleteTasks(at offsets: IndexSet, from completedItems: [Item], using modelContext: ModelContext) throws {
        for index in offsets {
            modelContext.delete(completedItems[index])
        }
        
        do {
            try modelContext.save()
        } catch {
            throw LogError.deleteFailed(error.localizedDescription)
        }
    }
    
    /// Clears all completed tasks
    func clearAll(_ completedItems: [Item], using modelContext: ModelContext) throws {
        for item in completedItems {
            modelContext.delete(item)
        }
        
        do {
            try modelContext.save()
        } catch {
            throw LogError.clearFailed(error.localizedDescription)
        }
    }
    
    /// Handles errors by setting the error message and showing the alert
    func handleError(_ error: Error) {
        if let logError = error as? LogError {
            errorMessage = logError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
    }
}

/// Errors that can occur during log operations
enum LogError: LocalizedError {
    case deleteFailed(String)
    case clearFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .deleteFailed(let message):
            return "Failed to delete task: \(message)"
        case .clearFailed(let message):
            return "Failed to clear tasks: \(message)"
        }
    }
}

