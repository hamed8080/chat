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
    
}
