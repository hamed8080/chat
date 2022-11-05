//
// ChatError.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

public enum ChatErrorCodes: String {
    case asyncError
    case outOfStorage
    case errorRaedyChat
    case exportError
    case networkError
    case undefined
}

public struct ChatError: Decodable {
    public var message: String?
    public var errorCode: Int?
    public var hasError: Bool?
    public var content: String?
    public var userInfo: [String: Any]?
    public var rawError: Error?
    public var code: ChatErrorCodes = .undefined
    public var banError: BanError?

    internal enum CodingKeys: String, CodingKey {
        case hasError
        case errorMessage
        case errorCode
        case code
        case content
        case message
    }

    public init(code: ChatErrorCodes = .undefined, errorCode: Int? = nil, message: String? = nil, userInfo: [String: Any]? = nil, rawError: Error? = nil, content: String? = nil) {
        self.code = code
        self.message = message
        self.userInfo = userInfo
        self.rawError = rawError
        self.errorCode = errorCode
        self.content = content
    }

    init(message: String? = nil, errorCode: Int? = nil, hasError: Bool? = nil, content: String? = nil) {
        self.message = message
        self.errorCode = errorCode
        self.hasError = hasError
        self.content = content
    }

    public init(from decoder: Decoder) throws {
        let containser = try? decoder.container(keyedBy: CodingKeys.self)
        hasError = try containser?.decodeIfPresent(Bool.self, forKey: .hasError)
        message = try containser?.decodeIfPresent(String.self, forKey: .errorMessage)
        errorCode = try containser?.decodeIfPresent(Int.self, forKey: .errorCode)
        content = try containser?.decodeIfPresent(String.self, forKey: .content)
        if let msg = try containser?.decodeIfPresent(String.self, forKey: .message) {
            message = msg
        }
        if let errorCode = try containser?.decodeIfPresent(Int.self, forKey: .code),
           errorCode == 208,
           let data = message?.data(using: .utf8),
           let banError = try? JSONDecoder().decode(BanError.self, from: data)
        {
            self.banError = banError
        }
    }
}

public class BanError: Decodable {
    private let errorMessage: String?
    private let duration: Int?
    private let uniqueId: String?
}

extension AsyncError {
    var chatError: ChatError {
        ChatError(code: .asyncError, message: message, userInfo: userInfo, rawError: rawError)
    }
}
