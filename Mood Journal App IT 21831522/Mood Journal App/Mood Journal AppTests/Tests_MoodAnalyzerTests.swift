import XCTest
@testable import Mood_Journal_App

final class MoodAnalyzerTests: XCTestCase {

    func testFallbackPositive() {
        let analyzer = MoodAnalyzer()
        analyzer.analyze(text: "I feel very happy and grateful today")

        let expectation = XCTestExpectation(description: "Wait for analysis")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(analyzer.currentResult?.label.lowercased(), "positive")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testFallbackNegative() {
        let analyzer = MoodAnalyzer()
        analyzer.analyze(text: "I am sad and tired")

        let expectation = XCTestExpectation(description: "Wait for analysis")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertEqual(analyzer.currentResult?.label.lowercased(), "negative")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
}
