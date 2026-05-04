//
//  EasymodeUITests.swift
//  EasymodeUITests
//
//  Created by Erik Kernan on 3/25/25.
//

import XCTest

final class EasymodeUITests: XCTestCase {
    private enum Timeout {
        static let short: TimeInterval = 2
        static let medium: TimeInterval = 5
        static let long: TimeInterval = 10
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        XCUIApplication().terminate()
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

        XCTAssertTrue(app.staticTexts["task.activeText"].waitForExistence(timeout: Timeout.long))
        XCTAssertTrue(app.buttons["task.complete"].waitForExistence(timeout: Timeout.long))
        XCTAssertEqual(app.staticTexts["task.activeText"].label, "Restore focus")

        // Give persisted task and launch state a moment to flush before relaunching on slower CI runners.
        sleep(1)
        app.terminate()

        app.launchEnvironment["UI_TEST_RESET_STATE"] = "false"
        app.launchEnvironment["UI_TEST_HAS_COMPLETED_ONBOARDING"] = "true"
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: Timeout.long))
        XCTAssertFalse(app.buttons["Get Started"].exists)
        XCTAssertTrue(app.staticTexts["task.activeText"].waitForExistence(timeout: Timeout.long))
        XCTAssertEqual(app.staticTexts["task.activeText"].label, "Restore focus")
        XCTAssertTrue(app.buttons["task.complete"].waitForExistence(timeout: Timeout.medium))
    }

    private func launchFreshApp() -> XCUIApplication {
        let app = XCUIApplication()
        if app.state != .notRunning {
            app.terminate()
        }
        app.launchArguments = ["-ui-testing"]
        app.launchEnvironment["UI_TEST_RESET_STATE"] = "true"
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
        XCTAssertTrue(startButton.waitForExistence(timeout: Timeout.medium))
        XCTAssertTrue(waitUntilHittable(startButton, timeout: Timeout.medium))
        startButton.tap()
    }

    private func waitUntilHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == true AND hittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
