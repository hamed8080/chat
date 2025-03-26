//
// ChatError.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Async
import Foundation

public enum ChatErrorType: String, Identifiable, CaseIterable, Sendable {
    public var id: Self { self }
    case asyncError
    case outOfStorage
    case errorRaedyChat
    case exportError
    case networkError
    case notAddedInUserGroup
    case undefined
}

public struct ChatError: Decodable, Sendable {
    public var message: String?
    public var code: Int?
    public var hasError: Bool?
    public var content: String?
    public var userInfo: [String: Sendable]?
    public var rawError: Error?
    public var type: ChatErrorType = .undefined
    public var banError: BanError?

    internal enum CodingKeys: String, CodingKey {
        case hasError
        case errorMessage
        case errorCode
        case code
        case content
        case message
    }

    public init(type: ChatErrorType = .undefined, code: Int? = nil, message: String? = nil, userInfo: [String: Sendable]? = nil, rawError: Error? = nil, content: String? = nil) {
        self.type = type
        self.message = message
        self.userInfo = userInfo
        self.rawError = rawError
        self.code = code
        self.content = content
    }

    public init(message: String? = nil, code: Int? = nil, hasError: Bool? = nil, content: String? = nil) {
        self.message = message
        self.code = code
        self.hasError = hasError
        self.content = content
    }

    public init(from decoder: Decoder) throws {
        let containser = try? decoder.container(keyedBy: CodingKeys.self)
        hasError = try containser?.decodeIfPresent(Bool.self, forKey: .hasError)
        message = try containser?.decodeIfPresent(String.self, forKey: .errorMessage)
        content = try containser?.decodeIfPresent(String.self, forKey: .content)
        if let msg = try containser?.decodeIfPresent(String.self, forKey: .message) {
            message = msg
        }
        let code = try? containser?.decodeIfPresent(Int.self, forKey: .code)
        let errorCode = try? containser?.decodeIfPresent(Int.self, forKey: .errorCode)
        let codeRes = code ?? errorCode
        self.code = codeRes ?? nil
        if self.code == 208, let data = message?.data(using: .utf8), let banError = try? JSONDecoder.instance.decode(BanError.self, from: data) {
            self.banError = banError
        }
    }
}

public struct BanError: Codable, Sendable, Hashable {
    public let errorMessage: String?
    public let duration: Int?
    public let uniqueId: String?
    
    public init(errorMessage: String?, duration: Int?, uniqueId: String?) {
        self.errorMessage = errorMessage
        self.duration = duration
        self.uniqueId = uniqueId
    }
    
    enum CodingKeys: CodingKey {
        case errorMessage
        case duration
        case uniqueId
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        self.duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        self.uniqueId = try container.decodeIfPresent(String.self, forKey: .uniqueId)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.errorMessage, forKey: .errorMessage)
        try container.encodeIfPresent(self.duration, forKey: .duration)
        try container.encodeIfPresent(self.uniqueId, forKey: .uniqueId)
    }
}

public extension AsyncError {
    var chatError: ChatError {
        ChatError(type: .asyncError, message: message, userInfo: userInfo, rawError: rawError)
    }
}
