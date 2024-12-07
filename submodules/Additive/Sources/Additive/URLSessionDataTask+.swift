//
// URLSessionDataTask+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
    func suspend()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

public struct SendableURLSessionDataTask: @unchecked Sendable {
    public let task: URLSessionDataTaskProtocol
    
    public init(task: URLSessionDataTaskProtocol) {
        self.task = task
    }
}

public extension URLSessionDataTaskProtocol {
    var sendable: SendableURLSessionDataTask { SendableURLSessionDataTask(task: self) }
}
