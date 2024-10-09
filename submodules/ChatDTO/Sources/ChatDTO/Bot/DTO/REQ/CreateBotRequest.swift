//
// CreateBotRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22


import Foundation

/// Create bot request.
public struct CreateBotRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    /// The name of the bot you want to create.
    public let botName: String
    public let uniqueId: String
    public var typeCodeIndex: Index

    /// Initializer.
    /// - Parameters:
    ///   - botName: The bot name you want to create.
    ///   - uniqueId: The unique id of request. If you manage the unique id by yourself you should leave this blank, otherwise, you must use it if you need to know what response is for what request.
    public init(botName: String, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.botName = botName
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case botName
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.botName, forKey: .botName)
    }
}
