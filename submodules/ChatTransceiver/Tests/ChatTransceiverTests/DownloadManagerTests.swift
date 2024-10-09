//
// DownloadManagerTests.swift
// Copyright (c) 2022 ChatTransceiver
//
// Created by Hamed Hosseini on 11/2/22
//
import Foundation
import XCTest
import Mocks
import Additive
@testable import ChatTransceiver

@available(iOS 13.0, *)
final class DownloadManagerTests: XCTestCase {

    private var sut: DownloadManager!
    private var mockURLSession: MockURLSession!
    private var exp: XCTestExpectation!

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockURLSession = MockURLSession()
        sut = DownloadManager()
    }

    func test_whenDownloadWithProgressCompletion_progressCompletionIsWorking() {
        let exp = expectation(description: "Expected to receive progress value in progress completion.")
        _ = sut.download(downloadParams(), mockURLSession) { progress in
            if progress.percent != 0 {
                exp.fulfill()
            }
        } completion: { (data, response, error) in }
        mockURLSession.callDownloadResponse()
        mockURLSession.callDownloadData()
        wait(for: [exp], timeout: 1)
    }

    func test_whenDownloadCompleted_progressIsSetTo100() {
        let exp = expectation(description: "Expected to progress percnet to be setted to 100.")
        _ = sut.download(downloadParams(), mockURLSession) { progress in
            if progress.percent == 100 {
                exp.fulfill()
            }
        } completion: { (data, response, error) in }
        mockURLSession.callDownloadResponse(lenght: 2048)
        mockURLSession.callDownloadData(lenght: 2048)
        mockURLSession.callDownloadDataCompleted()
        wait(for: [exp], timeout: 1)
    }

    func test_whenDownloadWithHeaders_requestContainsHeaders() {
        let headers: [String: String] = ["TEST_KEY": "TEST_VALUE"]
        let params = downloadParams(headers: headers)
        _ = sut.download(params, mockURLSession, progress: nil) { (_,_,_) in }
        let isExist = mockURLSession.request?.allHTTPHeaderFields?.contains(where: {$0.key == "TEST_KEY"}) ?? false
        XCTAssertTrue(isExist, "Expected header fields contain TEST_KEY.")
    }

    func test_whenDownloadNoHeaders_requestContainsHeadersMustBeEqualToOneAndTokenHeadersIsSetted() {
        let params = downloadParams()
        _ = sut.download(params, mockURLSession, progress: nil) { (_,_,_) in }
        XCTAssertEqual(mockURLSession.request?.allHTTPHeaderFields?.count ?? 0, 1, "Expected headers to be equal to 1 beacuse token should set automatically in header.")
    }

    func test_whenDownloadWithParams_requestContainsParameter() {
        let params = downloadParams(params: ["TEST_KEY": "TEST_VAKUE"])
        _ = sut.download(params, mockURLSession, progress: nil) { (_,_,_) in }
        let url = mockURLSession.request!.url!
        let comp = URLComponents(string: url.absoluteString)
        let isExist = comp?.queryItems?.contains(where: {$0.name == "TEST_KEY"}) ?? false
        XCTAssertTrue(isExist, "Expected the URL contains at least one query parameter.")
    }

    private func downloadParams(
        forceToDownload: Bool = false,
        url: URL = URL(string: "www.test.com")!,
        token: String = "FAKE_TOKEN",
        params: [String : Any]? = nil,
        headers: [String : String] = [:],
        thumbnail: Bool = false,
        hashCode: String? = nil,
        isImage: Bool = false,
        method: HTTPMethod = .get,
        uniqueId: String = UUID().uuidString
    ) -> DownloadManagerParameters {
        DownloadManagerParameters(forceToDownload: forceToDownload,
                                  url: url,
                                  token: token,
                                  params: params,
                                  headers: headers,
                                  thumbnail: thumbnail,
                                  hashCode: hashCode,
                                  isImage: isImage,
                                  method: method,
                                  uniqueId: uniqueId)
    }
}
