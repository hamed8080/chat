//
// SendChatMessageVO.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/9/22

import Async
import Foundation

public struct SendChatMessageVO: Codable {
    public let type: Int
    public let token: String?
    public var content: String?
    public var messageType: Int?
    public var metadata: String?
    public var repliedTo: Int?
    public var systemMetadata: String?
    public var subjectId: Int?
    public var tokenIssuer: Int? = 1
    public var typeCode: String?
    public var uniqueId: String?

    public init(type: Int,
                token: String,
                content: String? = nil,
                messageType: Int? = nil,
                metadata: String? = nil,
                repliedTo: Int? = nil,
                systemMetadata: String? = nil,
                subjectId: Int? = nil,
                tokenIssuer: Int = 1,
                typeCode: String? = nil,
                uniqueId: String? = nil)
    {
        self.type = type
        self.token = token
        self.content = content
        self.messageType = messageType
        self.metadata = metadata
        self.repliedTo = repliedTo
        self.systemMetadata = systemMetadata
        self.subjectId = subjectId
        self.tokenIssuer = tokenIssuer
        self.typeCode = typeCode
        self.uniqueId = uniqueId
    }

    public init(req: ChatSendable, token: String, typeCode: String) {
        type = req.chatMessageType.rawValue
        content = req.content
        messageType = (req as? MessageTypeProtocol)?.messageType.rawValue
        metadata = (req as? MetadataProtocol)?.metadata
        repliedTo = (req as? ReplyProtocol)?.repliedTo
        systemMetadata = (req as? SystemtMetadataProtocol)?.systemMetadata
        subjectId = (req as? SubjectProtocol)?.subjectId
        uniqueId = req.uniqueId
        self.token = token
        self.typeCode = typeCode
    }

    public init?(with asyncData: Data?) {
        do {
            guard let data = asyncData,
                  let asyncMessageData = try JSONDecoder.instance.decode(AsyncMessage.self, from: data).content?.data(using: .utf8),
                  let asyncMessageVOData = try JSONDecoder.instance.decode(SendAsyncMessageVO.self, from: asyncMessageData).content.data(using: .utf8) else { return nil }
            let chatMessage = try JSONDecoder.instance.decode(SendChatMessageVO.self, from: asyncMessageVOData)
            self = chatMessage
        } catch {
            return nil
        }
    }

    public init?(with asyncMessage: AsyncMessage?) {
        guard let data = asyncMessage?.content?.data(using: .utf8),
              let chatMessage = try? JSONDecoder.instance.decode(SendChatMessageVO.self, from: data) else { return nil }
        self = chatMessage
    }
}
