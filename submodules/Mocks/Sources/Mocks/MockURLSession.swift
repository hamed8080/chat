//
// HTTPURLResponse.swift
// Copyright (c) 2022 Mocks
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import Additive

public extension HTTPURLResponse {
    static func defaultSuccess(request: URLRequest) -> HTTPURLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }

    func defualtBadRequest(request: URLRequest) -> HTTPURLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
}

open class MockURLSession: @unchecked Sendable, URLSessionProtocol {
    public func canelAndInvalidate() {
        
    }
    
    public func uploadTask(streamRequest request: URLRequest) -> URLSessionUploadTask {
        fatalError("")
    }
    
    public func data(_ request: URLRequest) async throws -> (Data, URLResponse) {
        throw URLError(.badURL)
    }
    
    public func upload(_ request: URLRequest, _ data: Data) async throws -> (Data, URLResponse) {
        throw URLError(.badURL)
    }
    
    public var configuration: URLSessionConfiguration = URLSessionConfiguration.default
    public var delegate: URLSessionDelegate?
    public var delegateQueue: OperationQueue = .main

    public var data: Data?
    public var request: URLRequest?
    public var url: URL?
    public var response: HTTPURLResponse?
    public var error: Error?
    public var nextDataTask = MockURLSessionDataTask()
    public var uploadCompleitonHandler: ((Data?, URLResponse?, Error?) -> Void)?

    public init() {
    }

    public func dataTask(_ request: URLRequest, completionHandler: @escaping CompletionType) -> URLSessionDataTaskProtocol {
        self.request = request
        completionHandler(data, response, error)
        return nextDataTask
    }

    public func dataTask(_ request: URLRequest) -> URLSessionDataTaskProtocol {
        self.request = request
        return nextDataTask
    }

    public func dataTask(_ url: URL) -> URLSessionDataTaskProtocol {
        self.url = url
        return nextDataTask
    }
    
    public func uploadTask(_ request: URLRequest, _ completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> URLSessionDataTaskProtocol {
        self.request = request
        self.uploadCompleitonHandler = completion
        return nextDataTask
    }
    
    public func uploadTask(_ request: URLRequest, _ filePath: URL, _ completion: @escaping UploadCompletionType) -> URLSessionDataTaskProtocol {
        self.request = request
        self.uploadCompleitonHandler = completion
        return nextDataTask
    }

    public func callDownloadResponse(lenght: Int = 2048) {
        let response = HTTPURLResponse(url: URL(string: "www.test.com")!, mimeType: nil, expectedContentLength: lenght, textEncodingName: nil)
        (delegate as! URLSessionDataDelegate).urlSession?(URLSession.shared, dataTask: dummyTask, didReceive: response) { response in }
    }

    public func callDownloadData(lenght: Int = 500) {
        let data = makeData(lenght: lenght)
        (delegate as! URLSessionDataDelegate).urlSession?(URLSession.shared, dataTask: dummyTask, didReceive: data)
    }

    public func callURLSession() {
        (delegate as! URLSessionTaskDelegate).urlSession?(URLSession.shared, task: dummyTask, didCompleteWithError: nil)
    }

    private func makeData(lenght: Int = 500) -> Data {
        var data = Data(count: lenght)
        data.withUnsafeMutableBytes { bytes in
            arc4random_buf(bytes.baseAddress, lenght)
        }
        return data
    }

    public func callDownloadDataCompleted() {
        (delegate as! URLSessionDataDelegate).urlSession?(URLSession.shared, task: dummyTask, didCompleteWithError: nil)
    }

    public func callUploadProgress() {
        (delegate as! URLSessionTaskDelegate).urlSession?(URLSession.shared, task: dummyTask, didSendBodyData: 1024, totalBytesSent: 1024, totalBytesExpectedToSend: 2048)
    }
    
    private var dummyTask: URLSessionDataTask {
        let dummyReq = URLRequest(url: URL(string: "www.test.com")!)
        let task = URLSession.shared.dataTask(with: dummyReq)
        return task
    }
}
