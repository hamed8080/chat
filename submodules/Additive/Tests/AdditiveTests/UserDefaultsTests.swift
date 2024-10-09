import Foundation
import XCTest
@testable import Additive

final class UserDefaultsTests: XCTestCase {
    func testSetValueCodable_whenValidDataIsStored_saved() {
        // Given
        let value = User(name: "John", age: 35, retired: true, father: "James")
        // When
        UserDefaults.standard.setValue(codable: value, forKey: "USER")
        // Then
        let result: User = UserDefaults.standard.codableValue(forKey: "USER")!
        XCTAssertEqual(result.age, 35, "Expected the user.age to be equal to '35' but it's \(String(describing: result.age))")
        XCTAssertEqual(result.name, "John", "Expected the user.name to be equal to 'John' but it's \(String(describing: result.name))")
        XCTAssertEqual(result.father, "James", "Expected the user.father to be equal to 'James' but it's \(String(describing: result.father))")
        XCTAssertEqual(result.retired, true, "Expected the user.retired to be equal to 'false' but it's \(String(describing: result.retired))")
    }

    func testSetValueCodable_whenISNotValidDataIsStored_returnNilCodable() {
        // Given
        let value = "TEST"
        // When
        UserDefaults.standard.setValue(codable: value, forKey: "USER")
        // Then
        let result: User? = UserDefaults.standard.codableValue(forKey: "USER")
        XCTAssertNil(result, "Expected the user to be nil but it's \(String(describing: result))")
    }
}
