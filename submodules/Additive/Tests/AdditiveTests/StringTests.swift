import Foundation
import XCTest
@testable import Additive

final class StringTests: XCTestCase {

    func testRemoveBackslashes_whenInnerJsonHas_hasNewLine() {
        // Given
        let json = "[{\"name\": \"Hamed\", \"config\": \"{\"ip\": \"192.168.1.1\"}\", \"Staff\": \"[{\"name\": \"John\", \"id\": 1}]\"}]"
        // When
        let result = json.removeBackSlashes()
        // Then
        let expectionResult = "[{\"name\": \"Hamed\", \"config\": \n{\"ip\": \"192.168.1.1\"}\n, \"Staff\": \n[{\"name\": \"John\", \"id\": 1}]\n}]"
        XCTAssertEqual(result, expectionResult, "Expected the string to be equal to \(expectionResult) but it's \(String(describing: result))")
    }

    func testCapitalizeFirstLetter() {
        // Given
        var value = "hamed"
        // When
        value.capitalizeFirstLetter()
        // Then
        XCTAssertEqual(value, "Hamed", "Expected the string to be equal to 'Hamed' in uppercased mode but it's \(String(describing: value))")
    }

    func testIsNillOrEmpty_whenIsEmpty_returnTrue() {
        // Given
        let value: String? = ""
        // When
        let result = value.isEmptyOrNil
        // Then
        XCTAssertTrue(result, "Expected the string to be empty and equals to true but it's \(String(describing: result))")
    }

    func testIsNillOrEmpty_whenIsNil_returnTrue() {
        // Given
        let value: String? = nil
        // When
        let result = value.isEmptyOrNil
        // Then
        XCTAssertTrue(result, "Expected the string to be empty and equals to true but it's \(String(describing: result))")
    }

    func testIsNillOrEmpty_whenHasValue_returnFalse() {
        // Given
        let value: String? = "Test"
        // When
        let result = value.isEmptyOrNil
        // Then
        XCTAssertFalse(result, "Expected the string to be not empty and equals to false but it's \(String(describing: result))")
    }

    func testIsEnglish_whenNotEnglish_returnFalse() {
        // Given
        let value: String = "سلام"
        // When
        let result = value.isEnglishString
        // Then
        XCTAssertFalse(result, "Expected the string to be not 'سلام' and equals to false but it's \(String(describing: result))")
    }

    func testIsEnglish_whenNotEnglish_returnTrue() {
        // Given
        let value: String = "Test that the text is from The United State."
        // When
        let result = value.isEnglishString
        // Then
        XCTAssertTrue(result, "Expected to be equal to true but it's \(String(describing: result))")
    }

    #if canImport(UIKit)
    func testWidthOfString() {
        // Given
        let value: String = "Test that"
        // When
        let result = value.widthOfString(usingFont: .systemFont(ofSize: 16))
        // Then
        XCTAssertEqual(result, 63, accuracy: 1, "Expected the width of the string to be equal to 63 but it's \(String(describing: result))")
    }
    #endif

    func testLocalize() {
        // Given
        let value: String = "test_localize"
        // When
        let result = value.localized(bundle: .module)
        // Then
        XCTAssertEqual(result, "Test Localize", "Expected the string to be equal to 'Test Localize' but it's \(String(describing: result))")
    }

    func testMD5() {
        // Given
        let value: String = "TEST"
        // When
        let result = value.md5
        // Then
        XCTAssertEqual(result, "033bd94b1168d7e4f0d644c3c95e35bf", "Expected the md5 string to be equal to '033bd94b1168d7e4f0d644c3c95e35bf' but it's \(String(describing: result))")
    }

    @available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
    func testMD5NewVersion() {
        // Given
        let value: String = "TEST"
        // When
        let result = value.md5NewVersion
        // Then
        XCTAssertEqual(result, "033bd94b1168d7e4f0d644c3c95e35bf" , "Expected the md5 string to be equal to '033bd94b1168d7e4f0d644c3c95e35bf' but it's \(String(describing: result))")
    }

    func testMD5OlderVersion() {
        // Given
        let value: String = "TEST"
        // When
        let result = value.md5Older
        // Then
        XCTAssertEqual(result, "033bd94b1168d7e4f0d644c3c95e35bf", "Expected the md5 string to be equal to '033bd94b1168d7e4f0d644c3c95e35bf' but it's \(String(describing: result))")
    }
}
