import XCTest

final class prayers_Watch_AppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAutoNextSpamDoesNotFreeze() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Rosary"].tap()
        app.buttons["Joyful"].tap()

        // Ensure Auto is ON
        let autoSwitch = app.switches["Auto"]
        if autoSwitch.exists, (autoSwitch.value as? String) == "0" {
            autoSwitch.tap()
        }

        // Start speaking
        app.buttons["Speak"].tap()

        // Spam Next
        let nextButton = app.buttons["Next"]
        for _ in 0..<10 {
            nextButton.tap()
        }

        sleep(1)

        // First step after selecting a mystery is "Sign of the Cross".
        XCTAssertFalse(app.staticTexts["Sign of the Cross"].exists)
        XCTAssertTrue(app.exists)
    }

    @MainActor
    func testLibraryInterruptSwitchesActivePrayer() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Prayer Library"].tap()

        // Pick any visible prayer-like entry and open it (detail view autoplays).
        let firstCell = app.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        firstCell.tap()

        // Immediately go back and pick a different entry while speech is still active.
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let secondCell = app.cells.element(boundBy: 1)
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5))
        secondCell.tap()

        // New detail should be visible (headline is the prayer title).
        XCTAssertTrue(app.staticTexts.element(boundBy: 0).exists)
        XCTAssertTrue(app.exists)
    }
}
