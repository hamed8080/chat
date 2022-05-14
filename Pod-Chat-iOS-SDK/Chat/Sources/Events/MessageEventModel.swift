//
//  MessageEventModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
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
    
    init (type:MessageEventTypes , chatMessage:ChatMessage){
        let data = chatMessage.content?.data(using: .utf8) ?? Data()
        let messageEvent  = try? JSONDecoder().decode(MessageEvent.self, from: data)
        let message       = try? JSONDecoder().decode(Message.self, from: chatMessage.content?.data(using: .utf8) ?? Data())
        message?.threadId = chatMessage.subjectId
        message?.id       = message?.id ?? Int(chatMessage.content ?? "")
        self.type         = type
        self.message      = message
        self.threadId     = chatMessage.subjectId
        self.messageId    = messageEvent?.id ?? chatMessage.messageId ?? Int(chatMessage.content ?? "")
        self.senderId     = messageEvent?.senderId
        self.pinned       = messageEvent?.pinned
    }
    
}

struct MessageEvent:Decodable{
    public let threadId  : Int?
    public let id        : Int?
    public let senderId  : Int?
    public let pinned    : Bool?
}


public enum MessageEventTypes {
    case MESSAGE_NEW
    case MESSAGE_SEND
    case MESSAGE_DELIVERY
    case MESSAGE_SEEN
    case MESSAGE_EDIT
    case MESSAGE_DELETE
}
