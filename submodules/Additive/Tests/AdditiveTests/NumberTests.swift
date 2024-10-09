import Foundation
import XCTest
@testable import Additive

final class NumberTests: XCTestCase {

    func testToSizeString() {
        // Given
        let value = 1024
        // When
        let result = value.toSizeString()
        // Then
        if Locale.current.identifier.lowercased().contains("de") {
            XCTAssertEqual(result, "1,0 General.KB", "Expected the string to be equal to '1,0 General.KB' but it's \(String(describing: result))")
        } else {
            XCTAssertEqual(result, "1.0 General.KB", "Expected the string to be equal to '1.0 General.KB' but it's \(String(describing: result))")
        }
    }

    func testDate() {
        // Given
        let value = UInt(1681314000000)
        // When
        let result = value.date
        // Then
        let resultDate = result.getDate(localIdentifire: Locale.current.identifier)
        let resultTime = result.getTime(localIdentifire: Locale.current.identifier)
        if Locale.current.identifier.lowercased() == "en_us" {
            XCTAssertEqual(resultDate, "2023-04-12", "Expected the string to be equal to '2023-04-12' but it's \(String(describing: resultDate))")
            XCTAssertEqual(resultTime, "3:40 PM", "Expected the string to be equal to '3:40 PM' but it's \(String(describing: resultTime))")
        } else if Locale.current.identifier.lowercased().contains("ir") {
            XCTAssertEqual(resultDate, "1402-01-23", "Expected the string to be equal to '1402-01-23' but it's \(String(describing: resultDate))")
            XCTAssertEqual(resultTime, "15:40", "Expected the string to be equal to '15:40' but it's \(String(describing: resultTime))")
        } else if Locale.current.identifier.lowercased().contains("de") {
            XCTAssertEqual(resultDate, "2023-04-12", "Expected the string to be equal to '2023-04-12' but it's \(String(describing: resultDate))")
            XCTAssertEqual(resultTime, "15:40", "Expected the string to be equal to '15:40' but it's \(String(describing: resultTime))")
        }
    }
}
