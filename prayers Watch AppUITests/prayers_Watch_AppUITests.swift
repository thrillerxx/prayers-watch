import XCTest

final class prayers_Watch_AppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func assertAnyButtonExists(_ app: XCUIApplication, names: [String], file: StaticString = #filePath, line: UInt = #line) {
        for name in names {
            if app.buttons[name].exists { return }
        }
        XCTFail("Expected one of buttons to exist: \(names)", file: file, line: line)
    }

    @MainActor
    func testAutoNextSpamDoesNotFreeze() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Rosary"].tap()
        app.buttons["Joyful"].tap()

        // Pre-capture key controls *before* starting speech to avoid UI-idle wait flakiness.
        let autoSwitch = app.switches["Auto"]
        XCTAssertTrue(autoSwitch.waitForExistence(timeout: 3))

        let speakButton = app.buttons["Speak"]
        XCTAssertTrue(speakButton.waitForExistence(timeout: 3))

        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 3))

        // We should start on the first step.
        XCTAssertTrue(app.staticTexts["Sign of the Cross"].waitForExistence(timeout: 3))

        // Ensure Auto is ON.
        if (autoSwitch.value as? String) == "0" {
            autoSwitch.tap()
        }

        // Start speaking, then immediately spam Next while speech is active.
        speakButton.tap()

        for _ in 0..<10 {
            nextButton.tap()
        }

        // Give UI a moment to settle.
        sleep(1)

        // Assertion 1: title changed at least once.
        XCTAssertFalse(app.staticTexts["Sign of the Cross"].exists)

        // Assertion 2: still on the Rosary screen.
        XCTAssertTrue(app.switches["Auto"].exists)
        XCTAssertTrue(app.buttons["Next"].exists)

        // Assertion 3: a Speak/Pause control is still available.
        assertAnyButtonExists(app, names: ["Speak", "Pause", "Resume"])

        XCTAssertTrue(app.exists)
    }

    @MainActor
    func testLibraryInterruptSwitchesActivePrayer() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Prayer Library"].tap()

        let firstCell = app.cells.element(boundBy: 0)
        let secondCell = app.cells.element(boundBy: 1)

        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5))

        let prayer1Title = firstCell.label
        let prayer2Title = secondCell.label
        XCTAssertNotEqual(prayer1Title, "")
        XCTAssertNotEqual(prayer2Title, "")

        // Start playback on prayer 1 (detail view autoplays on appear).
        firstCell.tap()
        // Avoid long waits while speech starts; just verify we navigated to a detail screen.
        XCTAssertTrue(app.navigationBars.buttons.element(boundBy: 0).waitForExistence(timeout: 5))

        // Switch to prayer 2 while audio is active.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5))
        secondCell.tap()

        // Assert title changed to prayer 2 (best-effort; should be fast).
        XCTAssertTrue(app.staticTexts[prayer2Title].waitForExistence(timeout: 5))

        // Playback control should be present.
        assertAnyButtonExists(app, names: ["Speak", "Pause", "Resume"])

        XCTAssertTrue(app.exists)
    }
}
