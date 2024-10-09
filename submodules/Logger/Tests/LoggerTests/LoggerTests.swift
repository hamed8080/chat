import XCTest
import Mocks
import Additive
@testable import Logger

final class LoggerTests: XCTestCase, LogDelegate {
    var sut: Logger!
    var mockTimer: MockTimer!
    var mockURLSession: MockURLSession!
    var logResult: Log?
    var logExpectation: XCTestExpectation?
    var json = "[{ \"name\": \"hamed\" } ]"
    var userInfo = ["device": "ios"]
    var mockURL = URL(string: "https://www.test.com")!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockTimer = MockTimer()
        mockURLSession = MockURLSession()
        sut = Logger(
            config: LoggerConfig(
                prefix: "TEST_SDK",
                logServerURL: mockURL.absoluteString,
                persistLogsOnServer: true
            ),
            delegate: self,
            timer: mockTimer,
            urlSession: mockURLSession
        )
    }

    func testPrefixIsEqualToInitializerParameter() throws {
        XCTAssertEqual(sut.config.prefix, "TEST_SDK")
    }

    func testLogJSONTitle() {
        logExpectation = XCTestExpectation(description: "Test Title")
        sut.logJSON(title: "TITLE", jsonString: "", persist: false, type: .sent)
        wait(for: [logExpectation!], timeout: 1)
        XCTAssertTrue(logResult?.message?.contains("TITLE") ?? false)
    }

    func testLogJSON_removeBackslash() {
        // When
        logExpectation = XCTestExpectation(description: "Test Remove Backslashes")
        sut.logJSON(title: "", jsonString: json, persist: false, type: .sent)
        // Then
        wait(for: [logExpectation!], timeout: 1)
        XCTAssertFalse(logResult?.message?.contains("\\") ?? true)
    }

    func testLogJSON_type() {
        // When
        logExpectation = XCTestExpectation(description: "Test Type")
        sut.logJSON(title: "", jsonString: json, persist: false, type: .sent)
        // Then
        wait(for: [logExpectation!], timeout: 1)
        XCTAssertEqual(logResult?.type, .sent)
    }

    func testLogJSON_userInfo_isGreaterThanZero() {
        // When
        logExpectation = XCTestExpectation(description: "Test User Info")
        sut.logJSON(title: "", jsonString: json, persist: false, type: .sent, userInfo: userInfo)
        // Then
        wait(for: [logExpectation!], timeout: 1)
        XCTAssertGreaterThan(logResult?.userInfo?.count ?? 0, 0)
    }

    func testLogTitle() {
        logExpectation = XCTestExpectation(description: "Test Title")
        sut.log(title: "TITLE", message: "", persist: false, type: .sent)
        wait(for: [logExpectation!], timeout: 1)
        XCTAssertTrue(logResult?.message?.contains("TITLE") ?? false)
    }

    func testLog_removeBackslash() {
        // When
        logExpectation = XCTestExpectation(description: "Test Remove Backslashes")
        sut.log(title: "", message: json, persist: false, type: .sent)
        // Then
        wait(for: [logExpectation!], timeout: 1)
        XCTAssertFalse(logResult?.message?.contains("\\") ?? true)
    }

    func testLog_type() {
        // When
        logExpectation = XCTestExpectation(description: "Test Type")
        sut.log(title: "", message: json, persist: false, type: .sent)
        // Then
        wait(for: [logExpectation!], timeout: 1)
        XCTAssertEqual(logResult?.type, .sent)
    }

    func testLog_userInfo_isGreaterThanZero() {
        // When
        logExpectation = XCTestExpectation(description: "Test User Info")
        sut.log(title: "", message: json, persist: false, type: .sent, userInfo: userInfo)
        // Then
        wait(for: [logExpectation!], timeout: 1)
        XCTAssertGreaterThan(logResult?.userInfo?.count ?? 0, 0)
    }

    func testLog_persist_isOnTheCache() {
        // Given
        let beforeCount = (try? sut.persistentManager.context?.fetch(CDLog.fetchRequest()).count) ?? 0
        // When

        sut.log(title: "", message: json, persist: true, type: .sent, userInfo: userInfo)
        // Then
        let afetrCount = (try? sut.persistentManager.context?.fetch(CDLog.fetchRequest()).count) ?? 0
        XCTAssertGreaterThan(afetrCount, beforeCount)
    }

    func testInit_persistIsTrue_startSendingTimer() {
        // Given
        let expectation = XCTestExpectation(description: "Test Timer")
        // When
        sut.log(title: "TEST", message: json, persist: true, type: .sent, userInfo: userInfo)
        mockTimer.blockResult = { timer in
            expectation.fulfill()
        }
        mockTimer.fire()

        // Then
        wait(for: [expectation], timeout: 0)
    }

    private func makeRequest<T: Encodable>(request: URLRequest, type: T.Type) -> String {
        var output = "\(sut.config.prefix): \n"
        output += "Start Of Request====\n"
        output += " REST Request With Method:\(request.method.rawValue) - url:\(request.url?.absoluteString ?? "")\n"
        output += " With Headers:[]\n"
        output += " With HttpBody:\(request.httpBody?.jsonString ?? "nil")\n"
        output += " Expected DecodeType:\(String(describing: type))\n"
        output += "End Of Request====\n"
        output += "\n"
        return output
    }

    func testLogHttpRequest() {
        // Given
        logExpectation = XCTestExpectation(description: "Test log Http Request")
        sut = Logger(config: .init(prefix: "TEST_SDK", persistLogsOnServer: false), delegate: self)
        let req = URLRequest(url: mockURL)
        // When
        sut.logHTTPRequest(req, String(describing: String.self), persist: true, type: .sent)
        // Then
        let output = makeRequest(request: req, type: String.self)
        wait(for: [logExpectation!], timeout: 0)
        XCTAssertEqual(logResult?.message, output)
    }

    private func makeResponse(data: Data? = nil, withError: Error? = nil, addStartLineBreak: Bool = true) -> String {
        var output = "\(sut.config.prefix): \(addStartLineBreak ? "\n" : "")"
        output += "Start Of Response====\n"
        output += " REST Response For url:\(mockURL.absoluteString)\n"
        output += " With Data Result in Body:\(data?.utf8StringOrEmpty ?? "nil")\n"
        output += "End Of Response====\n"
        output += "\n"
        output += "Error:\(withError?.localizedDescription ?? "nil")"
        return output
    }

    func testLogHttpResponse() {
        // Given
        logExpectation = XCTestExpectation(description: "Test log Http Response")
        sut = Logger(config: .init(prefix: "TEST_SDK", persistLogsOnServer: false), delegate: self)
        let data = "response".data(using: .utf8)
        let request = URLRequest(url: mockURL)
        sut.logHTTPResponse(data, HTTPURLResponse.defaultSuccess(request: request), nil, persist: true, type: .received)
        // Then
        let output = makeResponse(data: data)
        wait(for: [logExpectation!], timeout: 0)
        XCTAssertEqual(logResult?.message, output)
    }

    func testLogHttpResponse_hasError_typeIsError() {
        // Given
        let error = URLError(.badURL)
        logExpectation = XCTestExpectation(description: "Test log Http Response")
        sut = Logger(config: .init(prefix: "TEST_SDK", persistLogsOnServer: false), delegate: self)
        let data = "response".data(using: .utf8)
        let request = URLRequest(url: mockURL)
        sut.logHTTPResponse(data, HTTPURLResponse.defaultSuccess(request: request), error, persist: true, type: .received)
        // Then
        let output = makeResponse(data: data, withError: error)
        wait(for: [logExpectation!], timeout: 0)
        XCTAssertEqual(logResult?.level, .error)
        XCTAssertEqual(logResult?.message, output)
    }

    func testSendLog_whenSendALog_called() {
        // Given
        logExpectation = XCTestExpectation(description: "Test send log")
        let request = URLRequest(url: mockURL)
        mockURLSession.data = "Response Data".data(using: .utf8)
        mockURLSession.response = HTTPURLResponse.defaultSuccess(request: request)
        // When
        sut.log(message: "TEST", persist: true, type: .sent)
        mockTimer.fire()
        // Then
    }

    func testClearLogs() {
        // Given
        let expectation = XCTestExpectation(description: "Test Clear logs")
        for i in 1 ..< 10 {
            let log = CDLog.insertEntity(sut.persistentManager.context!)
            log.prefix = sut.config.prefix
            log.userInfo = nil
            log.id = UUID().uuidString
            log.level = (LogLevel.error.rawValue) as NSNumber
            log.message = "message\(i)"
            log.time = (Date().timeIntervalSince1970) as NSNumber
            log.type = (LogEmitter.sent.rawValue) as NSNumber
        }
        try? sut.persistentManager.context?.save()

        let req = CDLog.fetchRequest()
        req.predicate = NSPredicate(format: "prefix == %@", sut.config.prefix)
        let beforeCount = (try? sut.persistentManager.context?.fetch(req).count) ?? 0
        // When
        Logger.clear(prefix: sut.config.prefix) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        // Then
        let afetrCount = (try? sut.persistentManager.context?.fetch(req).count) ?? 0
        XCTAssertLessThanOrEqual(afetrCount, beforeCount)
    }

    func onLog(log: Log) {
        logResult = log
        logExpectation?.fulfill()
    }
}
