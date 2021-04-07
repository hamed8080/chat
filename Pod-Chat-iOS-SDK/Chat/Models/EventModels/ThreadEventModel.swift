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
    public let unreadCount:     Int?
    public let pinMessage:      PinUnpinMessage?
    
    init(type: ThreadEventTypes, participants: [Participant]?, threads: [Conversation]?, threadId: Int?, senderId: Int?, unreadCount: Int?, pinMessage: PinUnpinMessage?) {
        self.type           = type
        self.participants   = participants
        self.threads        = threads
        self.threadId       = threadId
        self.senderId       = senderId
        self.unreadCount    = unreadCount
        self.pinMessage     = pinMessage
    }
    
    
    init(type:ThreadEventTypes , chatMessage:NewChatMessage , participants:[Participant]? = nil){
        self.type            = type
        let data             = chatMessage.content?.data(using : .utf8) ?? Data()
        let threadEvent      = try? JSONDecoder().decode(ThreadEvent.self, from : data)
        let threads          = try? JSONDecoder().decode(Conversation.self, from : data)
        self.participants    = participants ?? threadEvent?.participants 
        self.threads         = threads != nil ? [threads!] : nil
        threadId             = chatMessage.subjectId
        senderId             = threadEvent?.senderId
        unreadCount          = threadEvent?.unreadCount
        self.pinMessage      = try? JSONDecoder().decode(PinUnpinMessage.self, from : data)
    }
    
}

public struct ThreadEvent: Decodable {
    let participants  :[Participant]?
    let threads       :[Conversation]?
    let threadId      :Int?
    let senderId      :Int?
    let unreadCount   :Int?
}
