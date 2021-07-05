//
//  CreateCall.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public struct CreateCall : Codable {
    
    public let invitees     :[Invitee]?
    public let type         :CallType
    public let creatorId    :Int
    public let creator      :Participant
    public let conversation :Conversation
    public let threadId     :Int
    public let callId       :Int
    public let group        :Bool
    
    private enum CodingKeys:String,CodingKey{
        
        case invitees       = "invitees"
        case type           = "type"
        case creatorId      = "creatorId"
        case creator        = "creatorVO"
        case conversation   = "conversationVO"
        case threadId       = "threadId"
        case callId         = "callId"
        case group          = "group"
    }
}
