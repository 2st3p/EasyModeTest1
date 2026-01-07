//
//  Item.swift
//  EasyModeTest1
//
//  Created by Erik Kernan on 3/25/25.
//

import Foundation
import SwiftData

/// Represents a task in the EasyMode app
@Model
final class Item {
    /// The text content of the task
    var taskText: String
    /// When the task was created
    var timestamp: Date
    /// Whether the task is currently in progress
    var isInProgress: Bool
    /// Whether the task has been completed
    var isCompleted: Bool
    /// Whether the task has been cancelled
    var isCancelled: Bool
    /// When the task was completed
    var completedAt: Date?
    /// When the task was cancelled
    var cancelledAt: Date?
    
    init(
        taskText: String = "",
        timestamp: Date = .now,
        isInProgress: Bool = false,
        isCompleted: Bool = false,
        isCancelled: Bool = false,
        completedAt: Date? = nil,
        cancelledAt: Date? = nil
    ) {
        self.taskText = taskText
        self.timestamp = timestamp
        self.isInProgress = isInProgress
        self.isCompleted = isCompleted
        self.isCancelled = isCancelled
        self.completedAt = completedAt
        self.cancelledAt = cancelledAt
    }
}
