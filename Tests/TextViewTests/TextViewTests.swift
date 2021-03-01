import XCTest
@testable import TextView

final class TextViewTests: XCTestCase {
    
    func testNumberOfResults() {
        let reg = Regex.results(regExText: "Hello", targetText: "Hello, world!", caseSensitive: false, searchWithRegexCharacters: false)
        XCTAssertTrue(reg.count == 1)
    }
    
    func testRangeOfFirstResult() {
        let reg = Regex.results(regExText: "Hello", targetText: "Hello, world!", caseSensitive: false, searchWithRegexCharacters: false)
        XCTAssertTrue(reg.first != nil)
        XCTAssertTrue(reg.first!.range == NSRange(location: 0, length: 5))
    }
    
    func testCaseInsensitive() {
        let reg = Regex.results(regExText: "hello", targetText: "Hello, world!", caseSensitive: false, searchWithRegexCharacters: false)
        XCTAssertTrue(reg.count == 1)
    }
    
    func testCaseSensitive() {
        let reg = Regex.results(regExText: "hello", targetText: "Hello, world!", caseSensitive: true, searchWithRegexCharacters: false)
        XCTAssertTrue(reg.count == 0)
    }
    
    func testWithRegexCharacters() {
        let reg = Regex.results(regExText: "h.llo", targetText: "Hello, world!", caseSensitive: false, searchWithRegexCharacters: true)
        XCTAssertTrue(reg.count == 1)
    }
    
    func testWithoutRegexCharacters() {
        let reg = Regex.results(regExText: "h.llo", targetText: "Hello, world!", caseSensitive: false, searchWithRegexCharacters: false)
        XCTAssertTrue(reg.count == 0)
    }
}
