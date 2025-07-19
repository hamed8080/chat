//
// URLSession+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public protocol URLSessionProtocol: Sendable {
    typealias CompletionType = @Sendable (Data?, URLResponse?, Error?) -> Void
    typealias UploadCompletionType = @Sendable (Data?, URLResponse?, Error?) -> Void
    var configuration: URLSessionConfiguration { get }
    var delegate: URLSessionDelegate? { get }
    var delegateQueue: OperationQueue { get }
    func dataTask(_ request: URLRequest, completionHandler: @escaping @Sendable CompletionType) -> URLSessionDataTaskProtocol
    func data(_ request: URLRequest) async throws -> (Data, URLResponse)
    func dataTask(_ request: URLRequest) -> URLSessionDataTaskProtocol
    func dataTask(_ url: URL) -> URLSessionDataTaskProtocol
    func uploadTask(_ request: URLRequest, _ completion: @escaping @Sendable UploadCompletionType) -> URLSessionDataTaskProtocol
    func uploadTask(_ request: URLRequest, _ filePath: URL, _ completion: @escaping @Sendable UploadCompletionType) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    public func dataTask(_ request: URLRequest, completionHandler: @escaping @Sendable CompletionType) -> URLSessionDataTaskProtocol {
        dataTask(with: request, completionHandler: completionHandler)
    }

    public func dataTask(_ request: URLRequest) -> URLSessionDataTaskProtocol {
        dataTask(with: request)
    }

    public func dataTask(_ url: URL) -> URLSessionDataTaskProtocol {
        dataTask(with: url)
    }
    
    public func data(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }

    public func uploadTask(_ request: URLRequest, _ completion: @escaping @Sendable UploadCompletionType) -> URLSessionDataTaskProtocol {
        dataTask(with: request, completionHandler: completion)
    }
    
    public func uploadTask(_ request: URLRequest, _ filePath: URL, _ completion: @escaping @Sendable UploadCompletionType) -> URLSessionDataTaskProtocol {
        uploadTask(with: request, fromFile: filePath, completionHandler: completion)
    }
}
