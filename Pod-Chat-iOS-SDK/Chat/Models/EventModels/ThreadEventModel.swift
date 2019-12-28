//
//  ThreadEventModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/3/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class ThreadEventModel {
    
    public let type:            ThreadEventTypes
    public let participants:    [Participant]?
    public let threads:         [Conversation]?
    public let threadId:        Int?
    public let senderId:        Int?
    
    init(type: ThreadEventTypes, participants: [Participant]?, threads: [Conversation]?, threadId: Int?, senderId: Int?) {
        self.type           = type
        self.participants   = participants
        self.threads        = threads
        self.threadId       = threadId
        self.senderId       = senderId
    }
    
}
