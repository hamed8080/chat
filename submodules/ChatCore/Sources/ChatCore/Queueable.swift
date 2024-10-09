//
// Queueable.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Async
import Foundation

/// If a message is marked as Queueable, it can be resent automatically by SDK whenever chat is in `chatReady` state.
public protocol Queueable {
    var queueTime: Date { get set }
}

public protocol UniqueIdProtocol {
    var chatUniqueId: String { get }
}

public protocol TypeCodeIndexProtocol {
    typealias Index = Int
    var chatTypeCodeIndex: Index { get }
}

public protocol PeerNameProtocol {
    var peerName: String? { get }
}

public protocol AsyncSnedable: Encodable, PeerNameProtocol {
    var asyncMessageType: AsyncMessageTypes? { get set }
    var content: String? { get }
}

public final class AsyncChatServerMessage: AsyncSnedable {
    public var chatMessage: SendChatMessageVO
    public var peerName: String?
    public var asyncMessageType: AsyncMessageTypes? = .message
    public var content: String? { chatMessage.jsonString }

    public init(chatMessage: SendChatMessageVO, peerName: String? = nil) {
        self.chatMessage = chatMessage
        self.peerName = peerName
    }
}

/// If a message is marked as Chat Sendable, it will send the data to the async server and chat server afterward.
public protocol ChatSendable: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    var content: String? { get }
}

public protocol PlainTextSendable: ChatSendable {}

public protocol ReplyProtocol {
    var repliedTo: Int? { get }
}

public protocol MessageTypeProtocol {
    var _messageType: MessageType? { get }
}

public protocol MetadataProtocol {
    var metadata: String? { get }
}

public protocol SystemtMetadataProtocol {
    var systemMetadata: String? { get }
}

/// Some requests need subjectId for example for working with threads it's needed most of the time.
public protocol SubjectProtocol {
    var subjectId: Int { get }
}

public class BareChatSendableRequest: UniqueIdManagerRequest, ChatSendable {
    public var chatUniqueId: String {
        return uniqueId
    }
    public var content: String?

    public init(content: String? = nil, uniqueId: String? = nil, chatTypeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.content = content
        super.init(uniqueId: uniqueId, chatTypeCodeIndex: chatTypeCodeIndex)
    }
}
