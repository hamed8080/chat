//
//  TagParticipant.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/23/21.
//

import Foundation
public struct TagParticipant : Codable {
    
    public let  id           : Int?
    public let  active       : Bool?
    public let  tagId        : Int?
    public let  threadId     : Int?
    public let  conversation : Conversation?
    
    public init(id: Int? = nil, active: Bool? = nil, tagId: Int? = nil, threadId: Int? = nil, conversation: Conversation? = nil) {
        self.id           = id
        self.active       = active
        self.tagId        = tagId
        self.threadId     = threadId
        self.conversation = conversation
    }
    

    private enum CodingKeys:String , CodingKey{
        case  id             = "id"
        case  active         = "active"
        case  tagId          = "tagId"
        case  threadId       = "threadId"
        case  conversation   = "conversationVO"
    }
}
