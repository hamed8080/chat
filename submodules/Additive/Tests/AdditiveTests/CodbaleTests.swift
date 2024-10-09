import XCTest
@testable import Additive

final class CodableTests: XCTestCase {

    let user: User = .init(name: "John", age: 32, retired: true, father: nil)
    let array = [["name": "John"], ["name": "Sarah"]]
    let json = "[{\"name\":\"John\"},{\"name\":\"Sarah\"}]"
    let unEncodeable = ["number": Double.infinity]

    func testString_whenDataIsStringable_returnString() {
        let result = array.string
        XCTAssertEqual(result, json, "Expected the string to be equal to \(json) but it's \(String(describing: result))")
    }

    func testData_whenDataIsEncodable_isNotNil() {
        let result = json.data
        XCTAssertNotNil(result, "Expected the data to be not nil but it's \(String(describing: result))")
    }

    func testData_whenDataIsNotEncodable_isNil() {
        let result = unEncodeable.data
        XCTAssertNil(result, "Expected the data to be nil but it's \(String(describing: result))")
    }

    func testString_whenDataIsNotEncodable_isNil() {
        let result = unEncodeable.string
        XCTAssertNil(result, "Expected the string to be nil but it's \(String(describing: result))")
    }

    func testPrettyStringData_whenStringIsNotPretty_returnPrettyString() {
        // given
        let data = array.dataPrettyPrint
        // Then
        let expectation = "[\n  {\n    \"name\" : \"John\"\n  },\n  {\n    \"name\" : \"Sarah\"\n  }\n]"
        // Then
        let result = data?.utf8String
        XCTAssertEqual(result, expectation, "Expected the string to be equal to \(expectation) but it's \(String(describing: result))")
    }

    func testParameterData_when_returnData() {
        // When
        let data = user.parameterData
        // Then
        let result = data!.utf8String!
        XCTAssertTrue(result.contains("name=John") && result.contains("age=32") && result.contains("retired=1"), "Expected the string contains 'name=John','age=32','retired=1' but it's \(String(describing: result))")
        if #available(iOS 16.0, *) {
            let ampersandCount = result.split(separator: "&").count
            XCTAssertEqual(ampersandCount, 3, "Expected the ampersandCount to be equal to 3 but it's \(String(describing: ampersandCount))")
        } else {
            let ampersandCount = result.components(separatedBy: "&").count
            XCTAssertEqual(ampersandCount, 3, "Expected the ampersandCount to be equal to 3 but it's \(String(describing: ampersandCount))")
        }
    }

    func testParameterData_whenDataISNotEncodable_returnNil() {
        let result = unEncodeable.parameterData
        XCTAssertNil(result, "Expected the data to be not nil but it's \(String(describing: result))")
    }

    func testAsDictionary_when_returnDictionary() throws {
        // When
        let dic = try user.asDictionary()
        // Then
        let result = dic.count
        XCTAssertEqual(result, 3, "Expected the count to be equal to 3 but it's \(String(describing: result))")
    }

    func testAsDictionary_whenISUnencoable_throwAnError() {
        XCTAssertThrowsError(try unEncodeable.asDictionary(), "Expected to throw an error, but it did not.")
    }

    func testAsDictionary_whenISUnserializableString_throwAnError() {
        XCTAssertThrowsError(try "[name=2]".asDictionary(), "Expected to throw an error, but it did not.")
    }

    func testAsDictionaryNullable_when_returnDictionary() throws {
        // When
        let dic = try user.asDictionaryNuallable()
        // Then
        let result = dic.count
        XCTAssertEqual(result, 3, "Expected the count to be equal to 3 but it's \(String(describing: result))")
    }

    func testAsDictionaryNullable_whenUnEncodable_returnThrowAnError() {
        XCTAssertThrowsError(try unEncodeable.asDictionaryNuallable(), "Expected to throw an error, but it did not.")
    }

    func testAsDictionaryNullable_wheniSUnSerializable_returnThrowAnError() {
        XCTAssertThrowsError(try "[name=2]".asDictionaryNuallable(), "Expected to throw an error, but it did not.")
    }

    func testJsonString_whenEncodeObject_returnJson() throws {
        let result = user.jsonString
        let expectation = "{\"name\":\"John\",\"age\":32,\"retired\":true}"
        XCTAssertEqual(result, expectation, "Expected the result to be equal to \(expectation) but it's \(String(describing: result))")
    }

    func testJsonString_whenUnencodable_returnNil() throws {
        let result = unEncodeable.jsonString
        XCTAssertNil(result, "Expected the result to be nil but it's \(String(describing: result))")
    }
}

