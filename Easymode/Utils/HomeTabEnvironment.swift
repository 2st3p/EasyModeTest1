//
//  HomeTabEnvironment.swift
//  EasyModeTest1
//
//  Lets deep-linked screens (e.g. Log empty state) jump back to Home without tight coupling.
//

import SwiftUI

private struct SelectHomeTabActionKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    /// Switches the root tab bar to Home (index 0).
    var selectHomeTab: () -> Void {
        get { self[SelectHomeTabActionKey.self] }
        set { self[SelectHomeTabActionKey.self] = newValue }
    }
}
