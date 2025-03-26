import Foundation
import XCTest


final class DataTests: XCTestCase {

    func testUtf8String() {
        // Given
        let data = "TEST".data(using: .utf8)
        // When
        let result = data?.utf8String
        // Then
        XCTAssertEqual(result, "TEST", "Expected the string to be equal to TEST but it's \(String(describing: result))")
    }

    func testUtf8StringOrEmpty_whenHasValue_returnString() {
        // Given
        let data: Data? = "TEST".data(using: .utf8)
        // When
        let result = data?.utf8StringOrEmpty
        // Then
        XCTAssertEqual(result, "TEST", "Expected the string to be equal to TEST but it's \(String(describing: result))")
    }

    func testUtf8StringOrEmpty_whenIsEmpty_returnEmpty() {
        // Given
        let data: Data? = "".data(using: .utf8)
        // When
        let result = data?.utf8StringOrEmpty
        // Then
        XCTAssertEqual(result, "", "Expected the string to be an empty string but it's \(String(describing: result))")
    }

    func testImageScale_whenImageIsValid_returnReducedVersion() throws {
        // Given
        let url = Bundle.module.url(forResource: "icon", withExtension: "png")!
        let data = try Data(contentsOf: url)
        // When
        let result = data.imageScale(width: 128)?.0.width
        // Then
        XCTAssertEqual(result, 128, "Expected the width to be equal to 128 but it's \(String(describing: result))")
    }

    func testImageScale_whenImageIsNotValid_returnNil() {
        // Given
        let data = "TEST".data!
        // When
        let result = data.imageScale(width: 128)
        // Then
        XCTAssertNil(result, "Expected the data to be no nil but it's \(String(describing: result))")
    }
}
