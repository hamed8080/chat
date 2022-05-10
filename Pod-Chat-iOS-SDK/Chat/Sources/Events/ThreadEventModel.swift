//
//  ThreadEventModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
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
    
    init(type: ThreadEventTypes, participants: [Participant]? = nil, threads: [Conversation]? = nil, threadId: Int? = nil, senderId: Int? = nil, unreadCount: Int? = nil, pinMessage: PinUnpinMessage? = nil) {
        self.type           = type
        self.participants   = participants
        self.threads        = threads
        self.threadId       = threadId
        self.senderId       = senderId
        self.unreadCount    = unreadCount
        self.pinMessage     = pinMessage
    }
    
    
    init(type:ThreadEventTypes , chatMessage:ChatMessage , participants:[Participant]? = nil){
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

public enum ThreadEventTypes {
    case THREAD_CLOSED
    case THREAD_UNREAD_COUNT_UPDATED
    case THREAD_LAST_ACTIVITY_TIME
    case THREAD_PIN
    case THREAD_UNPIN
    case THREAD_INFO_UPDATED
    case THREAD_ADD_ADMIN
    case THREAD_REMOVE_ADMIN
    case THREAD_ADD_PARTICIPANTS
    case THREAD_LEAVE_SAFTLY_FAILED
    case THREAD_LEAVE_PARTICIPANT
    case THREAD_REMOVED_FROM
    case THREAD_MUTE
    case THREAD_UNMUTE
    case THREADS_LIST_CHANGE
    case THREAD_PARTICIPANTS_LIST_CHANGE
    case THREAD_DELETE
    case THREAD_NEW
    case THREAD_REMOVE_PARTICIPANTS
    case MESSAGE_PIN
    case MESSAGE_UNPIN
}
