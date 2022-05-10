//
//  MessageResponse.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
public class MessageResponse{
    
    public var threadId:        Int?
    public var participantId:   Int?
    public var messageId:       Int?
    public var message:         Message?
    
    public init(message: Message?,messageId: Int?, threadId: Int?,participantId: Int?) {
        self.threadId      = threadId
        self.participantId = participantId
        self.messageId     = messageId
        self.message       = message
    }
}


public class SentMessageResponse : MessageResponse{
    
    public var isSent : Bool
    
    public init(isSent:Bool , messageId:Int? = nil , threadId:Int? = nil , message:Message? = nil , participantId:Int? = nil) {
        self.isSent        = isSent
        super.init(message: message, messageId: messageId, threadId: threadId, participantId: participantId)
    }
}


public class DeliverMessageResponse : MessageResponse{
    
    public var isDeliver : Bool
    
    public init(isDeliver:Bool , messageId:Int? = nil , threadId:Int? = nil ,  message:Message? = nil , participantId:Int? = nil) {
        self.isDeliver     = isDeliver
        super.init(message: message, messageId: messageId, threadId: threadId, participantId: participantId)
    }
}


public class SeenMessageResponse : MessageResponse{
    
    public var isSeen : Bool
    
    public init(isSeen:Bool , messageId:Int? = nil , threadId:Int? = nil , message:Message? = nil , participantId:Int? = nil) {
        self.isSeen        = isSeen
        super.init(message: message, messageId: messageId, threadId: threadId, participantId: participantId)
    }
}
