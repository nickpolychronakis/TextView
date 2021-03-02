import XCTest
@testable import TextView

final class TextViewTests: XCTestCase {
    
    // MARK: RANGE
    func testRangeOfFirstResult() {
        let reg = Regex.results(regExText: "Hello", targetText: "Hello, world!", caseSensitive: false, diacriticSensitive: false, searchWithRegexCharacters: false)
        XCTAssertTrue(reg.first != nil)
        XCTAssertTrue(reg.first!.range == NSRange(location: 0, length: 5))
    }
    
    // MARK: CASE
    func testCaseInsensitive() {
        let reg = Regex.results(regExText: "heLlo", targetText: "Hello, world!", caseSensitive: false, diacriticSensitive: false, searchWithRegexCharacters: false)
        XCTAssertTrue(reg.count == 1)
    }
    
    func testCaseSensitive() {
        let reg = Regex.results(regExText: "heLlo", targetText: "Hello, world!", caseSensitive: true, diacriticSensitive: false, searchWithRegexCharacters: false)
        XCTAssertTrue(reg.count == 0)
    }
    
    // MARK: DIACRITIC
    func testDiacriticInsensitive() {
        let reg = Regex.results(regExText: "hello", targetText: "héllo, world", caseSensitive: false, diacriticSensitive: false, searchWithRegexCharacters: false)
        XCTAssertTrue(reg.count == 1)
    }
    
    func testDiacriticSensitive() {
        let reg = Regex.results(regExText: "hello", targetText: "héllo, world", caseSensitive: false, diacriticSensitive: true, searchWithRegexCharacters: false)
        XCTAssertTrue(reg.count == 0)
    }
    
    // MARK: REGEX
    func testWithRegexCharacters() {
        let reg = Regex.results(regExText: "h.llo", targetText: "hello, world", caseSensitive: false, diacriticSensitive: false, searchWithRegexCharacters: true)
        XCTAssertTrue(reg.count == 1)
    }
    
    func testWithoutRegexCharacters() {
        let reg = Regex.results(regExText: "h.llo", targetText: "Hello, world!", caseSensitive: false, diacriticSensitive: false, searchWithRegexCharacters: false)
        XCTAssertTrue(reg.count == 0)
    }
}
