import Foundation
import XCTest
@testable import Additive

final class URLRequestTests: XCTestCase {

    func testHttpMethod_whenHttpMthodIsDefault_returnGETEnum() {
        // Given
        let url = URL(string: "test")!
        let request = URLRequest(url: url)
        // Then
        let result = request.method
        XCTAssertEqual(result, .get, "Expected the mehod to be equal to '.get' but it's \(String(describing: result))")
    }

    func testMethod_whenIsPost_returnPostEnum() {
        // Given
        let url = URL(string: "test")!
        var request = URLRequest(url: url)
        // When
        request.httpMethod = "POST"
        // Then
        let result = request.method
        XCTAssertEqual(result, .post, "Expected the mehod to be equal to '.post' but it's \(String(describing: result))")
    }

    func testMethod_whenIsNotValidMethod_returnGetAsDefault() {
        // Given
        let url = URL(string: "test")!
        var request = URLRequest(url: url)
        // When
        request.httpMethod = "WRONG"
        // Then
        let result = request.method
        XCTAssertEqual(result, .get, "Expected the mehod to be equal to '.get' but it's \(String(describing: result))")
    }

    func testMethod_whenIsGet_returnGETString() {
        // Given
        let url = URL(string: "test")!
        var request = URLRequest(url: url)
        // When
        request.method = .get
        // Then
        let result = request.httpMethod
        XCTAssertEqual(result, "GET", "Expected the mehod value to be equal to 'GET' but it's \(String(describing: result))")
    }

    func testHttpMethod_whenIsGet_returnGETEnum() {
        // Given
        let url = URL(string: "test")!
        var request = URLRequest(url: url)
        // When
        request.httpMethod = "GET"
        // Then
        let result = request.method
        XCTAssertEqual(result, .get, "Expected the mehod to be equal to '.get' but it's \(String(describing: result))")
    }
}
