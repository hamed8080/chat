//
// StartCallRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatModels

public struct StartCallRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let threadId: Int?
    public let invitees: [Invitee]?
    public let type: CallType
    public let isFrontCamera: Bool
    public let client: SendClient
    public let createCallThreadRequest: CreateCallThreadRequest?
    public let uniqueId: String
    public var thread: Conversation?
    public var contacts: [Contact]?
    public var isVideoOn: Bool { type == .video }
    public var groupName: String = "group"
    public var isThreadCall: Bool { thread != nil }
    public var isContactCall: Bool { contacts != nil }
    public var isGroupCall: Bool { contacts?.count ?? 0 > 1 || thread?.group == true }
    public var callDetail: CreateCallThreadRequest? { .init(title: groupName) }
    public var typeCodeIndex: Index

    public var titleOfCalling: String {
        if isThreadCall {
            return thread?.title ?? groupName
        } else if isContactCall {
            return contacts?.first?.user?.username ?? "\(contacts?.first?.firstName ?? "") \(contacts?.first?.lastName ?? "")"
        } else if isGroupCall {
            return groupName
        } else {
            return ""
        }
    }

    public init(client: SendClient,
                contacts: [Contact]? = nil,
                thread: Conversation? = nil,
                threadId: Int? = nil,
                invitees: [Invitee]? = nil,
                type: CallType,
                isFrontCamera: Bool = true,
                groupName: String = "group",
                createCallThreadRequest: CreateCallThreadRequest? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.contacts = contacts
        self.groupName = groupName
        self.invitees = invitees ?? contacts?.map { Invitee(id: "\($0.id ?? 0)", idType: .contactId) }
        self.threadId = threadId ?? thread?.id
        self.thread = thread
        self.type = type
        self.isFrontCamera = isFrontCamera
        self.client = client
        self.createCallThreadRequest = createCallThreadRequest
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case threadId
        case invitees
        case type
        case client = "creatorClientDto"
        case createCallThreadRequest
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(client, forKey: .client)
        try container.encodeIfPresent(threadId, forKey: .threadId)
        try container.encodeIfPresent(invitees, forKey: .invitees)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(createCallThreadRequest, forKey: .createCallThreadRequest)
    }
}
