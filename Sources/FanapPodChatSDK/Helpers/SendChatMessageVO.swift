//
// SendChatMessageVO.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public struct SendChatMessageVO: Encodable {
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

    let type: Int
    let token: String
    var content: String?
    var messageType: Int?
    var metadata: String?
    var repliedTo: Int?
    var systemMetadata: String?
    var subjectId: Int?
    var tokenIssuer: Int = 1
    var typeCode: String?
    var uniqueId: String?
}
