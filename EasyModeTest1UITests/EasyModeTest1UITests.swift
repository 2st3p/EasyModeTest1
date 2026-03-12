//
//  EasyModeTest1UITests.swift
//  EasyModeTest1UITests
//
//  Created by Erik Kernan on 3/25/25.
//

import XCTest

final class EasyModeTest1UITests: XCTestCase {
    private enum Timeout {
        static let short: TimeInterval = 2
        static let medium: TimeInterval = 5
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingToFirstTaskCompletion() throws {
        let app = launchFreshApp()
        completeOnboarding(in: app)
        enterTask("Write spec", in: app)

        XCTAssertTrue(app.buttons["task.complete"].waitForExistence(timeout: Timeout.medium))
        app.buttons["task.complete"].tap()

        app.tabBars.buttons["Log"].tap()
        XCTAssertTrue(app.staticTexts["log.title"].waitForExistence(timeout: Timeout.medium))
    }

    @MainActor
    func testActiveSessionRestoresOnRelaunch() throws {
        let app = launchFreshApp()
        completeOnboarding(in: app)
        enterTask("Restore focus", in: app)

        XCTAssertTrue(app.staticTexts["task.activeText"].waitForExistence(timeout: Timeout.medium))
        XCTAssertEqual(app.staticTexts["task.activeText"].label, "Restore focus")
        app.terminate()

        let relaunchedApp = XCUIApplication()
        relaunchedApp.launch()

        XCTAssertFalse(relaunchedApp.buttons["Get Started"].exists)
        XCTAssertTrue(relaunchedApp.tabBars.buttons["Home"].waitForExistence(timeout: Timeout.medium))
        XCTAssertTrue(relaunchedApp.staticTexts["task.activeText"].waitForExistence(timeout: Timeout.medium))
        XCTAssertEqual(relaunchedApp.staticTexts["task.activeText"].label, "Restore focus")
        XCTAssertTrue(relaunchedApp.buttons["task.complete"].exists)
    }

    private func launchFreshApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launch()
        return app
    }

    private func completeOnboarding(in app: XCUIApplication) {
        let getStarted = app.buttons["Get Started"]
        XCTAssertTrue(getStarted.waitForExistence(timeout: Timeout.medium))
        getStarted.tap()

        let grantPermission = app.buttons["Grant Permission"]
        XCTAssertTrue(grantPermission.waitForExistence(timeout: Timeout.medium))
        grantPermission.tap()

        let skipForNow = app.buttons["Skip for Now"]
        XCTAssertTrue(skipForNow.waitForExistence(timeout: Timeout.medium))
        skipForNow.tap()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: Timeout.medium))
    }

    private func enterTask(_ taskText: String, in app: XCUIApplication) {
        let input = app.textFields["task.input"].firstMatch
        if input.waitForExistence(timeout: Timeout.short) {
            input.tap()
            input.typeText(taskText)
        } else {
            let fallback = app.textViews["task.input"].firstMatch
            XCTAssertTrue(fallback.waitForExistence(timeout: Timeout.medium))
            fallback.tap()
            fallback.typeText(taskText)
        }

        let startButton = app.buttons["task.start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: Timeout.short))
        startButton.tap()
    }
}
