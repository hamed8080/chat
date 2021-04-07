//
//  MessageEventModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/3/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class MessageEventModel {
    
    public let type:        MessageEventTypes
    public let message:     Message?
    public let threadId:    Int?
    public let messageId:   Int?
    public let senderId:    Int?
    public let pinned:      Bool?
    
    
    init(type: MessageEventTypes, message: Message?, threadId: Int?, messageId: Int?, senderId: Int?, pinned: Bool?) {
        self.type       = type
        self.message    = message
        self.threadId   = threadId
        self.messageId  = messageId
        self.senderId   = senderId
        self.pinned     = pinned
    }
    
    init (type:MessageEventTypes , chatMessage:NewChatMessage){
        let data = chatMessage.content?.data(using: .utf8) ?? Data()
        let messageEvent = try? JSONDecoder().decode(MessageEvent.self, from: data)
        let message      = Message(threadId: chatMessage.subjectId, pushMessageVO: chatMessage.content?.convertToJSON() ?? [:])
        message.id       = message.id ?? Int(chatMessage.content ?? "")
        self.type        = type
        self.message     = message
        self.threadId    = chatMessage.subjectId
        self.messageId   = messageEvent?.id ?? chatMessage.messageId ?? Int(chatMessage.content ?? "")
        self.senderId    = messageEvent?.senderId
        self.pinned      = messageEvent?.pinned
    }
    
}

struct MessageEvent:Decodable{
    public let threadId  : Int?
    public let id        : Int?
    public let senderId  : Int?
    public let pinned    : Bool?
}
