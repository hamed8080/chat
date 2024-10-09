import Foundation
import XCTest
@testable import Additive

final class URLTests: XCTestCase {

    let filePath = "file://test/insidefolder/picture.jpg"
    let urlString: String = "http://www.example.com"

    func testAppendQueryItems_whenHasValue_appendedAtEnd() {
        // Given
        let json = ["name": "John"]
        var url = URL(string: urlString)!
        // When
        url.appendQueryItems(with: json)
        // Then
        let expectationResult = "http://www.example.com?name=John"
        let result = url.absoluteString
        XCTAssertEqual(result, expectationResult, "Expected the url absoluteString string to be equal to '\(expectationResult)' but it's \(String(describing: result))")
    }

    func testAppendQueryItemsiOS15_whenHasValue_appendedAtEnd() {
        // Given
        let json = ["name": "John"]
        var url = URL(string: urlString)!
        let queryItems = try! url.makeQueryItems(encodable: json)
        // When
        url.appendQueryItems(queryItems!)
        // Then
        let expectationResult = "http://www.example.com?name=John"
        let result = url.absoluteString
        XCTAssertEqual(result, expectationResult, "Expected the url absoluteString string to be equal to '\(expectationResult)' but it's \(String(describing: result))")
    }

    func testAppendQueryItems_whenHasNotValue_appendedNothingAtEnd() {
        // Given
        let json = [String: String]()

        var url = URL(string: urlString)!
        // When
        url.appendQueryItems(with: json)
        // Then
        let result = url.absoluteString
        XCTAssertEqual(result, urlString, "Expected the url absoluteString string to be equal to '\(urlString)' but it's \(String(describing: result))")
    }

    func testAppendQueryItems_whenHasNotValue_appendedNothingAtEndOfCurrentQueryItems() {
        // Given
        let json = [String: String]()
        let urlString: String = "\(urlString)?name=John"
        var url = URL(string: urlString)!
        // When
        url.appendQueryItems(with: json)
        // Then
        let result = url.absoluteString
        XCTAssertEqual(result, urlString, "Expected the url absoluteString string to be equal to '\(urlString)' but it's \(String(describing: result))")
    }

    func testPathExtension_whenIsValidFileURL_returnValue() {
        // Given
        let url = URL(string: filePath)!
        // Then
        let result = url.fileExtension
        let expectationResult = "jpg"
        XCTAssertEqual(result, expectationResult, "Expected the ext to be equal to '\(expectationResult)' but it's \(String(describing: result))")
    }
    func testPathExtension_whenIsNotValidFileURL_returnNil() {
        // Given
        let url = URL(string: urlString)!
        // Then
        let result = url.fileExtension
        let expectationResult = ""
        XCTAssertEqual(result, expectationResult, "Expected the ext to be equal to '\(expectationResult)' but it's \(String(describing: result))")
    }

    func testFileName_whenIsValidFileURL_returnFileName() {
        // Given
        let url = URL(string: filePath)!
        // Then
        let result = url.fileName
        let expectationResult = "picture"
        XCTAssertEqual(result, expectationResult, "Expected the fileName to be equal to '\(expectationResult)' but it's \(String(describing: result))")
    }

    func testFileNameWithExtension_whenIsValidFileURL_returnFileNameWithExtension() {
        // Given
        let url = URL(string: filePath)!
        // Then
        let result = url.fileNameWithExtension
        let expectationResult = "picture.jpg"
        XCTAssertEqual(result, expectationResult, "Expected the fileNameWithExtension string to be equal to '\(expectationResult)' but it's \(String(describing: result))")
    }

    func testFileNameWithExtension_whenIsNotValidFileURL_returnFileNameWithExtensionNil() {
        // Given
        let url = URL(string: urlString)!
        // When
        let result = url.fileNameWithExtension
        // Then
        XCTAssertNil(result, "Expected the fileNameWirhExtension to be nil but it's \(String(describing: result))")
    }

    func testImageScale_whenImageIsValid_returnReducedVersion() {
        // Given
        let url = Bundle.module.url(forResource: "icon", withExtension: "png")!
        // Then
        let result = url.imageScale(width: 128)?.0.width
        XCTAssertEqual(result, 128, "Expected the width of the image to be equal to '128' but it's \(String(describing: result))")
    }

    func testImageScale_whenImageURLIsNotValid_returnNil() {
        // Given
        let url = URL(string: urlString)!
        // Then
        let result = url.imageScale(width: 128)
        XCTAssertNil(result, "Expected the result type of the with function to be nil but it's \(String(describing: result))")
    }

#if canImport(MobileCoreServices)
    func testMimeType_whenIsFile_returnMimeType() {
        // Given
        let url = URL(string: filePath)!
        // Then
        let result = url.mimeType
        let expectationResult = "image/jpeg"
        XCTAssertEqual(result, expectationResult, "Expected the mimetype to be equal to '\(expectationResult)' but it's \(String(describing: result))")
    }

    func testMimeTypeiOS15_whenIsFile_returnMimeType() {
        // Given
        let url = URL(string: filePath)!
        // Then
        let result = url.ios15MimeType
        let expectationResult = "image/jpeg"
        XCTAssertEqual(result, expectationResult, "Expected the mimetype to be equal to '\(expectationResult)' but it's \(String(describing: result))")
    }

    func testMimeTypeiOS14_whenIsFile_returnMimeType() {
        // Given
        let url = URL(string: filePath)!
        // Then
        let result = url.ios14MimeType
        let expectationResult = "image/jpeg"
        XCTAssertEqual(result, expectationResult, "Expected the mimetype to be equal to '\(expectationResult)' but it's \(String(describing: result))")
    }
#endif
}
