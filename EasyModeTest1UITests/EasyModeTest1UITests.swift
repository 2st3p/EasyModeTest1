//
//  EasyModeTest1UITests.swift
//  EasyModeTest1UITests
//
//  Created by Erik Kernan on 3/25/25.
//

import XCTest

final class EasyModeTest1UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testOnboardingToFirstTaskCompletion() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launch()

        app.buttons["Get Started"].tap()
        app.buttons["Grant Permission"].tap()
        app.buttons["Skip for Now"].tap()

        let input = app.textFields["task.input"].firstMatch
        if !input.exists {
            let fallback = app.textViews["task.input"].firstMatch
            XCTAssertTrue(fallback.waitForExistence(timeout: 2))
            fallback.tap()
            fallback.typeText("Write spec")
        } else {
            XCTAssertTrue(input.waitForExistence(timeout: 2))
            input.tap()
            input.typeText("Write spec")
        }

        app.buttons["task.start"].tap()
        app.buttons["task.complete"].tap()

        app.tabBars.buttons["Log"].tap()
        XCTAssertTrue(app.staticTexts["log.title"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
