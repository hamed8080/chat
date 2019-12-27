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
    public let message:     Message
    public let threadId:    Int?
    public let senderId:    Int?
    
    init(type: MessageEventTypes, message: Message, threadId: Int?, senderId: Int?) {
        self.type       = type
        self.message    = message
        self.threadId   = threadId
        self.senderId   = senderId
    }
    
}
