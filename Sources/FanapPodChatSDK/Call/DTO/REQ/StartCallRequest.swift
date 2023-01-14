//
// StartCallRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class StartCallRequest: UniqueIdManagerRequest, ChatSendable {
    public let threadId: Int?
    public let invitees: [Invitee]?
    public let type: CallType
    public let client: SendClient
    public let createCallThreadRequest: CreateCallThreadRequest?
    public var chatMessageType: ChatMessageVOTypes = .startCallRequest
    public var content: String? { convertCodableToString() }
    public var thread: Conversation?
    public var contacts: [Contact]?
    public var isVideoOn: Bool { type == .videoCall }
    public var groupName: String = "group"
    public var isThreadCall: Bool { thread != nil }
    public var isContactCall: Bool { contacts != nil }
    public var isGroupCall: Bool { contacts?.count ?? 0 > 1 || thread?.group == true }
    public var callDetail: CreateCallThreadRequest? { .init(title: groupName) }

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
                groupName: String = "group",
                createCallThreadRequest: CreateCallThreadRequest? = nil,
                uniqueId: String? = nil)
    {
        self.contacts = contacts
        self.groupName = groupName
        self.invitees = invitees ?? contacts?.map { Invitee(id: "\($0.id ?? 0)", idType: .contactId) }
        self.threadId = threadId ?? thread?.id
        self.thread = thread
        self.type = type
        self.client = client
        self.createCallThreadRequest = createCallThreadRequest
        super.init(uniqueId: uniqueId)
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
