//
// URLSession+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public protocol URLSessionProtocol {
    typealias CompletionType = (Data?, URLResponse?, Error?) -> Void
    var configuration: URLSessionConfiguration { get }
    var delegate: URLSessionDelegate? { get }
    var delegateQueue: OperationQueue { get }
    func dataTask(_ request: URLRequest, completionHandler: @escaping CompletionType) -> URLSessionDataTaskProtocol
    func dataTask(_ request: URLRequest) -> URLSessionDataTaskProtocol
    func dataTask(_ url: URL) -> URLSessionDataTaskProtocol
    func uploadTask(_ request: URLRequest, _ completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    public func dataTask(_ request: URLRequest, completionHandler: @escaping CompletionType) -> URLSessionDataTaskProtocol {
        dataTask(with: request, completionHandler: completionHandler)
    }

    public func dataTask(_ request: URLRequest) -> URLSessionDataTaskProtocol {
        dataTask(with: request)
    }

    public func dataTask(_ url: URL) -> URLSessionDataTaskProtocol {
        dataTask(with: url)
    }

    public func uploadTask(_ request: URLRequest, _ completion: @escaping ((Data?, URLResponse?, Error?) -> Void)) -> URLSessionDataTaskProtocol {
        dataTask(with: request, completionHandler: completion)
    }
}
