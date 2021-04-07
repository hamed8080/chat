//
//  Message.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Message : Codable {
    
    public var deletable:   Bool?
    public var delivered:   Bool?
    public var editable:    Bool?
    public var edited:      Bool?
    public var id:          Int?
    public var mentioned:   Bool?
    public var message:     String?
    public var messageType: Int?
    public var metadata:    String?
    public var ownerId:     Int?
    public var pinned:      Bool?
    public var previousId:  Int?
    public var seen:        Bool?
    public var systemMetadata:  String?
    public var threadId:    Int?
    public var time:        UInt?
    public var timeNanos:   UInt?
//    public let timeNanos:   UInt?
    public var uniqueId:    String?
    
    public var conversation:    Conversation?
    public var forwardInfo:     ForwardInfo?
    public var participant:     Participant?
    public var replyInfo:       ReplyInfo?
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(threadId: Int?, pushMessageVO: JSON) {
        
        self.threadId       = threadId
        self.deletable      = pushMessageVO["deletable"].bool
        self.delivered      = pushMessageVO["delivered"].bool
        self.editable       = pushMessageVO["editable"].bool
        self.edited         = pushMessageVO["edited"].bool
        self.id             = pushMessageVO["id"].int
        self.mentioned      = pushMessageVO["mentioned"].bool
        self.message        = pushMessageVO["message"].string
        self.messageType    = pushMessageVO["messageType"].int
        self.metadata       = pushMessageVO["metadata"].string
        self.pinned         = pushMessageVO["pinned"].bool
        self.previousId     = pushMessageVO["previousId"].int
        self.seen           = pushMessageVO["seen"].bool
        self.systemMetadata = pushMessageVO["systemMetadata"].string
        self.time           = pushMessageVO["time"].uInt
        self.timeNanos      = pushMessageVO["timeNanos"].uInt
        self.uniqueId       = pushMessageVO["uniqueId"].string
        
//        let timeNano = pushMessageVO["timeNanos"].uIntValue
//        let timeTemp = pushMessageVO["time"].uIntValue
//        self.time = ((UInt(timeTemp / 1000)) * 1000000000 ) + timeNano
        
        if (pushMessageVO["conversation"] != JSON.null) {
            self.conversation = Conversation(messageContent: pushMessageVO["conversation"])
        }
        
        if (pushMessageVO["forwardInfo"] != JSON.null) {
            self.forwardInfo = ForwardInfo(messageContent: pushMessageVO["forwardInfo"])
        }
        
        if (pushMessageVO["participant"] != JSON.null) {
            let tempParticipant = Participant(messageContent: pushMessageVO["participant"], threadId: threadId)
            self.participant = tempParticipant
            let tempOwnerId = tempParticipant.formatToJSON()["id"].int
            self.ownerId = tempOwnerId
        }
        
        if (pushMessageVO["replyInfoVO"] != JSON.null) {
            self.replyInfo = ReplyInfo(messageContent: pushMessageVO["replyInfoVO"])
        }
        
    }
    
    public init(threadId:       Int?,
                deletable:      Bool?,
                delivered:      Bool?,
                editable:       Bool?,
                edited:         Bool?,
                id:             Int?,
                mentioned:      Bool?,
                message:        String?,
                messageType:    Int?,
                metadata:       String?,
                ownerId:        Int?,
                pinned:         Bool?,
                previousId:     Int?,
                seen:           Bool?,
                systemMetadata: String?,
                time:           UInt?,
                timeNanos:      UInt?,
                uniqueId:       String?,
                conversation:   Conversation?,
                forwardInfo:    ForwardInfo?,
                participant:    Participant?,
                replyInfo:      ReplyInfo?) {
        
        self.threadId       = threadId
        self.deletable      = deletable
        self.delivered      = delivered
        self.editable       = editable
        self.edited         = edited
        self.id             = id
        self.mentioned      = mentioned
        self.message        = message
        self.messageType    = messageType
        self.metadata       = metadata
        self.ownerId        = participant?.id
        self.pinned         = pinned
        self.previousId     = previousId
        self.seen           = seen
        self.systemMetadata = systemMetadata
        self.time           = time
        self.timeNanos      = timeNanos
        self.uniqueId       = uniqueId
        self.conversation   = conversation
        self.forwardInfo    = forwardInfo
        self.participant    = participant
        self.replyInfo      = replyInfo
    }
    
    
    public init(theMessage: Message) {
        
        self.threadId       = theMessage.threadId
        self.deletable      = theMessage.deletable
        self.delivered      = theMessage.delivered
        self.editable       = theMessage.editable
        self.edited         = theMessage.edited
        self.id             = theMessage.id
        self.mentioned      = theMessage.mentioned
        self.message        = theMessage.message
        self.messageType    = theMessage.messageType
        self.metadata       = theMessage.metadata
        self.ownerId        = theMessage.participant?.id
        self.pinned         = theMessage.pinned
        self.previousId     = theMessage.previousId
        self.seen           = theMessage.seen
        self.systemMetadata = theMessage.systemMetadata
        self.time           = theMessage.time
        self.timeNanos      = theMessage.timeNanos
        self.uniqueId       = theMessage.uniqueId
        self.conversation   = theMessage.conversation
        self.forwardInfo    = theMessage.forwardInfo
        self.participant    = theMessage.participant
        self.replyInfo      = theMessage.replyInfo
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    func formatDataToMakeMessage() -> Message {
        return self
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    func formatToJSON() -> JSON {
        let result: JSON = ["deletable":        deletable ?? NSNull(),
                            "delivered":        delivered ?? NSNull(),
                            "editable":         editable ?? NSNull(),
                            "edited":           edited ?? NSNull(),
                            "id":               id ?? NSNull(),
                            "mentioned":        mentioned ?? NSNull(),
                            "message":          message ?? NSNull(),
                            "messageType":      messageType ?? NSNull(),
                            "metadata":         metadata ?? NSNull(),
                            "ownerId":          ownerId ?? NSNull(),
                            "pinned":           pinned ?? NSNull(),
                            "previousId":       previousId ?? NSNull(),
                            "seen":             seen ?? NSNull(),
                            "systemMetadata":   systemMetadata ?? NSNull(),
                            "threadId":         threadId ?? NSNull(),
                            "time":             time ?? NSNull(),
                            "timeNanos":        timeNanos ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull(),
                            "conversation":     conversation?.formatToJSON() ?? NSNull(),
                            "forwardInfo":      forwardInfo?.formatToJSON() ?? NSNull(),
                            "participant":      participant?.formatToJSON() ?? NSNull(),
                            "replyInfo":        replyInfo?.formatToJSON() ?? NSNull()]
        return result
    }
	
	private enum CodingKeys: String ,CodingKey{
		case deletable  = "deletable"
		case delivered = "delivered"
		case editable = "editable"
		case edited = "edited"
		case id = "id"
		case mentioned = "mentioned"
		case message = "message"
		case messageType = "messageType"
		case metadata = "metadata"
		case pinned = "pinned"
		case previousId = "previousId"
		case seen = "seen"
		case systemMetadata = "systemMetadata"
		case time = "time"
		case timeNanos = "timeNanos"
		case uniqueId = "uniqueId"
		case conversation = "conversation"
		case forwardInfo = "forwardInfo"
		case participant = "participant"
		case replyInfoVO = "replyInfoVO"
		case ownerId = "ownerId" // only in Encode
		case replyInfo = "replyInfo" // only in Encode
		case threadId = "threadId" // only in Encode
	}
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.deletable  = try container.decodeIfPresent(Bool.self, forKey: .deletable)
		self.delivered  = try container.decodeIfPresent(Bool.self, forKey: .delivered)
		self.editable  = try container.decodeIfPresent(Bool.self, forKey: .editable)
		self.edited  = try container.decodeIfPresent(Bool.self, forKey: .edited)
		self.id  = try container.decodeIfPresent(Int.self, forKey: .id)
		self.mentioned  = try container.decodeIfPresent(Bool.self, forKey: .mentioned)
		self.message  = try container.decodeIfPresent(String.self, forKey: .message)
		self.messageType  = try container.decodeIfPresent(Int.self, forKey: .messageType)
		self.metadata  = try container.decodeIfPresent(String.self, forKey: .metadata)
		self.pinned  = try container.decodeIfPresent(Bool.self, forKey: .pinned)
		self.previousId  = try container.decodeIfPresent(Int.self, forKey: .previousId)
		self.seen  = try container.decodeIfPresent(Bool.self, forKey: .seen)
		self.systemMetadata  = try container.decodeIfPresent(String.self, forKey: .systemMetadata)
		self.time  = try container.decodeIfPresent(UInt.self, forKey: .time)
		self.timeNanos  = try container.decodeIfPresent(UInt.self, forKey: .timeNanos)
		self.uniqueId  = try container.decodeIfPresent(String.self, forKey: .uniqueId)
		self.conversation  = try container.decodeIfPresent(Conversation.self, forKey: .conversation)
		self.forwardInfo  = try container.decodeIfPresent(ForwardInfo.self, forKey: .forwardInfo)
		self.participant  = try container.decodeIfPresent(Participant.self, forKey: .participant)
		self.ownerId = participant?.id
		self.replyInfo  = try container.decodeIfPresent(ReplyInfo.self, forKey: .replyInfoVO)
		
		//self.threadId       = threadId
		
	}
    
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(deletable, forKey: .deletable)
		try container.encodeIfPresent(delivered, forKey: .delivered)
		try container.encodeIfPresent(editable, forKey: .editable)
		try container.encodeIfPresent(edited, forKey: .edited)
		try container.encodeIfPresent(id, forKey: .id)
		try container.encodeIfPresent(mentioned, forKey: .mentioned)
		try container.encodeIfPresent(message, forKey: .message)
		try container.encodeIfPresent(messageType, forKey: .messageType)
		try container.encodeIfPresent(metadata, forKey: .metadata)
		try container.encodeIfPresent(ownerId, forKey: .ownerId)
		try container.encodeIfPresent(previousId, forKey: .previousId)
		try container.encodeIfPresent(seen, forKey: .seen)
		try container.encodeIfPresent(systemMetadata, forKey: .systemMetadata)
		try container.encodeIfPresent(threadId, forKey: .threadId)
		try container.encodeIfPresent(time, forKey: .time)
		try container.encodeIfPresent(timeNanos, forKey: .timeNanos)
		try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
		try container.encodeIfPresent(conversation, forKey: .conversation)
		try container.encodeIfPresent(forwardInfo, forKey: .forwardInfo)
		try container.encodeIfPresent(participant, forKey: .participant)
		try container.encodeIfPresent(replyInfo, forKey: .replyInfo)
		
	}
}
