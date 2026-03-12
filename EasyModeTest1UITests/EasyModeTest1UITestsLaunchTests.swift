//
//  EasyModeTest1UITestsLaunchTests.swift
//  EasyModeTest1UITests
//
//  Created by Erik Kernan on 3/25/25.
//

import XCTest

final class EasyModeTest1UITestsLaunchPerformanceTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launch()
            app.terminate()
        }
    }
}
