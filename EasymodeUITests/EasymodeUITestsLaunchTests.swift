//
//  EasymodeUITestsLaunchTests.swift
//  EasymodeUITests
//
//  Created by Erik Kernan on 3/25/25.
//

import XCTest

final class EasymodeUITestsLaunchPerformanceTests: XCTestCase {
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
