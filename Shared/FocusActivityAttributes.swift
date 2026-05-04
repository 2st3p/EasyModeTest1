//
//  FocusActivityAttributes.swift
//  Easymode
//
//  Defines the data model for Focus Session Live Activities.
//  Add this file to: Main App, EasyModeLiveActivity extension
//

import Foundation
import ActivityKit

/// Attributes for the Focus Session Live Activity
/// Displays the current task on Lock Screen and Dynamic Island
struct FocusActivityAttributes: ActivityAttributes {
    
    /// Dynamic state that can be updated during the activity
    public struct ContentState: Codable, Hashable {
        /// Whether app blocking is currently active
        var isBlocking: Bool
    }
    
    /// The task text being focused on (static, set at start)
    var taskText: String
    
    /// When the focus session started
    var startTime: Date
}
