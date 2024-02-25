//
// URLSession+.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
protocol URLSessionProtocol {
    func dataTask(_ request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    func decode<T: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ChatResponse<T>
}

extension URLSession: URLSessionProtocol {
    func dataTask(_ request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTask(with: request, completionHandler: completionHandler)
    }
}

extension URLSessionProtocol {
    func decode<T: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ChatResponse<T> {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        if let data = data, let chatError = try? JSONDecoder().decode(ChatError.self, from: data), chatError.hasError == true {
            return ChatResponse(error: chatError, typeCode: nil)
        } else if statusCode >= 200, statusCode <= 300, let data = data, let codable = try? JSONDecoder().decode(T.self, from: data) {
            return ChatResponse(result: codable, typeCode: nil)
        } else if let error = error {
            let error = ChatError(message: "\(ChatErrorType.networkError.rawValue) \(error)", code: statusCode, hasError: true)
            return ChatResponse(error: error, typeCode: nil)
        } else {
            let error = ChatError(message: "\(ChatErrorType.networkError.rawValue)", code: statusCode, hasError: true)
            return ChatResponse(error: error, typeCode: nil)
        }
    }
}
