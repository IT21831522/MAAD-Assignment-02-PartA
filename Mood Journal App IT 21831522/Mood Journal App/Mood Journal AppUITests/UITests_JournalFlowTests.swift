import XCTest

final class JournalFlowUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testAddAndDeleteEntryFlow() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Add Journal Entry"].tap()

        let editor = app.textViews.firstMatch
        editor.tap()
        editor.typeText("Today I feel great and excited about learning.")

        app.buttons["Analyze My Mood"].tap()

        let saveButton = app.buttons["Save Entry"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5))
        saveButton.tap()

        app.buttons["View All Entries"].tap()

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        firstCell.swipeLeft()
        firstCell.buttons["Delete"].tap()
    }
}
