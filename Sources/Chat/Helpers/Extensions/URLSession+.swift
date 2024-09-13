//
// URLSession+.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import Additive
import ChatCore
import Foundation

extension URLSessionProtocol {
    func decode<T: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?, typeCode: String?) -> ChatResponse<T> {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        if let data = data, let chatError = try? JSONDecoder.instance.decode(ChatError.self, from: data), chatError.hasError == true {
            return ChatResponse(error: chatError, typeCode: typeCode)
        } else if statusCode >= 200, statusCode <= 300, let data = data, let codable = try? JSONDecoder.instance.decode(T.self, from: data) {
            return ChatResponse(result: codable, typeCode: typeCode)
        } else if let error = error {
            let error = ChatError(message: "\(ChatErrorType.networkError.rawValue) \(error)", code: statusCode, hasError: true)
            return ChatResponse(error: error, typeCode: typeCode)
        } else {
            let error = ChatError(message: "\(ChatErrorType.networkError.rawValue)", code: statusCode, hasError: true)
            return ChatResponse(error: error, typeCode: typeCode)
        }
    }
}
