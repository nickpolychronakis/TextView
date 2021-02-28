import XCTest
@testable import TextView

final class TextViewTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TextView().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
