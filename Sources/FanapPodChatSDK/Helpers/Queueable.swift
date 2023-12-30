//
// Queueable.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

/// If a message is marked as Queueable, it can be resent automatically by SDK whenever chat is in `chatReady` state.
protocol Queueable {
    var queueTime: Date { get set }
}

protocol UniqueIdProtocol {
    var uniqueId: String { get }
}

public protocol TypeCodeIndexProtocol {
    typealias Index = Int
    var typeCodeIndex: Index { get }
}

protocol PeerNameProtocol {
    var peerName: String? { get }
}

protocol AsyncSnedable: Encodable, PeerNameProtocol {
    var asyncMessageType: AsyncMessageTypes? { get set }
    var content: String? { get }
}

class AsyncChatServerMessage: AsyncSnedable {
    var chatMessage: SendChatMessageVO
    var peerName: String?
    var asyncMessageType: AsyncMessageTypes? = .message
    var content: String? { chatMessage.convertCodableToString() }

    init(chatMessage: SendChatMessageVO, peerName: String? = nil) {
        self.chatMessage = chatMessage
        self.peerName = peerName
    }
}

/// If a message is marked as Chat Sendable, it will send the data to the async server and chat server afterward.
protocol ChatSendable: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    var chatMessageType: ChatMessageVOTypes { get set }
    var content: String? { get }
}

protocol PlainTextSendable: ChatSendable {}

protocol ReplyProtocol {
    var repliedTo: Int? { get }
}

protocol MessageTypeProtocol {
    var messageType: MessageType { get }
}

protocol MetadataProtocol {
    var metadata: String? { get }
}

protocol SystemtMetadataProtocol {
    var systemMetadata: String? { get }
}

/// Some requests need subjectId for example for working with threads it's needed most of the time.
protocol SubjectProtocol {
    var subjectId: Int { get }
}

class BareChatSendableRequest: UniqueIdManagerRequest, ChatSendable {
    var content: String?
    var chatMessageType: ChatMessageVOTypes = .unknown

    init(content: String? = nil, uniqueId: String? = nil, chatMessageType: ChatMessageVOTypes = .unknown, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.content = content
        self.chatMessageType = chatMessageType
        super.init(uniqueId: uniqueId, typeCodeIndex: typeCodeIndex)
    }
}

protocol BodyRequestProtocol {}
