//
//  BlockedApp.swift
//  Easymode
//
//  Created by Erik Kernan on 3/25/25.
//

import SwiftUI
import SwiftData

/// Represents an app that has been selected for blocking
@Model
final class BlockedApp {
    /// The bundle identifier of the blocked app
    var bundleID: String
    /// The display name of the blocked app
    var appName: String
    /// When the app was last modified/selected
    var lastModified: Date
    
    init(bundleID: String, appName: String) {
        self.bundleID = bundleID
        self.appName = appName
        self.lastModified = Date()
    }
} 