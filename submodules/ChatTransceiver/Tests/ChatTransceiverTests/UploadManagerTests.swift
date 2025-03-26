//
// UploadManagerTests.swift
// Copyright (c) 2022 ChatTransceiver
//
// Created by Hamed Hosseini on 11/2/22
//
import Foundation
import XCTest
import Mocks
import Additive
import ChatDTO
@testable import ChatTransceiver

@available(iOS 13.0, *)
final class UploadManagerTests: XCTestCase {

    private var sut: UploadManager!
    private var mockURLSession: MockURLSession!
    private var exp: XCTestExpectation!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockURLSession = MockURLSession()
        sut = UploadManager()
    }

    func test_whenUploadWithHeader_requestContainHeader() {

        let exp = expectation(description: "Expected the header contains greater than zero.")
        _ = sut.upload(fileParams(), Data())
        wait(for: [exp], timeout: 1)
    }


    private func fileReq(
        data: Data = Data(),
        fileExtension: String? = "pdf",
        fileName: String? =  "fake",
        description: String? = nil,
        isPublic: Bool = false,
        mimeType: String? = "applicaiotn/pdf",
        originalName: String? = "fake.pdf",
        userGroupHash: String? = "XMXMXMX"
    ) -> UploadFileRequest {
        UploadFileRequest(data: data,
                          fileExtension: fileExtension,
                          fileName: fileName,
                          description: description,
                          isPublic: isPublic,
                          mimeType: mimeType,
                          originalName: originalName,
                          userGroupHash: userGroupHash)
    }

    private func fileParams(
        fileRequest: UploadFileRequest? = nil,
        token: String = "FAKE_TOKEN",
        fileServer: String = ""
    ) -> UploadManagerParameters {
        UploadManagerParameters(fileRequest ?? fileReq(),
                                token: token,
                                fileServer: fileServer)
    }
}
