//
//  ReplyInfo.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ReplyInfo : Codable {
    /*
     * + replyInfoVO        ReplyInfo:
     *  - deleted:             Bool?            // Delete state of Replied Message
     *  - repliedToMessageId:  Int?             // Id of Replied Message
     *  - message:             String?          // Content of Replied Message
     *  - messageType:         Int?             // Type of Replied Message
     *  - metadata:            String?          // metadata of Replied Message
     *  - systemMetadata:      String?          // systemMetadata of Replied Message
     *  - participant          Participant?     // Sender of Replied Message
     *  - repliedToMessage     String?
     *  - repliedToMessageId   Int?
     */
    
    
    public var deleted:             Bool?
    public var repliedToMessageId:  Int?
    public var message:             String?
    public var messageType:         Int?
    public var metadata:            String?
    public var systemMetadata:      String?
	public var repliedToMessageTime :UInt? = nil
	public var repliedToMessageNanos:UInt? = nil
//    public let timeNanos:           UInt?
	
	
	public var time: UInt?
    
    public var participant:        Participant?
    //    public let repliedToMessage:    String?
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(messageContent: JSON) {
        
        self.deleted            = messageContent["deleted"].bool
        self.message            = messageContent["message"].string
        self.messageType        = messageContent["messageType"].int
        self.metadata           = messageContent["metadata"].string
        self.repliedToMessageId = messageContent["repliedToMessageId"].int
        self.systemMetadata     = messageContent["systemMetadata"].string
        
		self.repliedToMessageNanos = messageContent["repliedToMessageNanos"].uIntValue
		self.repliedToMessageTime = messageContent["repliedToMessageTime"].uIntValue
		if let repliedToMessageTime = repliedToMessageTime , let repliedToMessageNanos = repliedToMessageNanos{
			self.time =  ((UInt(repliedToMessageTime / 1000)) * 1000000000 ) + repliedToMessageNanos
		}
		
        if (messageContent["participant"] != JSON.null) {
            self.participant = Participant(messageContent: messageContent["participant"], threadId: nil)
        } else {
            self.participant = nil
        }
        
    }
    
    public init(deleted:            Bool?,
                repliedToMessageId: Int?,
                message:            String?,
                messageType:        Int?,
                metadata:           String?,
                systemMetadata:     String?,
                time:               UInt?,
                participant:        Participant?) {

        self.deleted            = deleted
        self.repliedToMessageId = repliedToMessageId
        self.message            = message
        self.messageType        = messageType
        self.metadata           = metadata
        self.systemMetadata     = systemMetadata
        self.time               = time
        self.participant        = participant
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(theReplyInfo: ReplyInfo) {
        self.deleted            = theReplyInfo.deleted
        self.repliedToMessageId = theReplyInfo.repliedToMessageId
        self.message            = theReplyInfo.message
        self.messageType        = theReplyInfo.messageType
        self.metadata           = theReplyInfo.metadata
        self.systemMetadata     = theReplyInfo.systemMetadata
        self.time               = theReplyInfo.time
        self.participant        = theReplyInfo.participant
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatDataToMakeReplyInfo() -> ReplyInfo {
        return self
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatToJSON() -> JSON {
        let result: JSON = ["participant":          participant?.formatToJSON() ?? NSNull(),
                            "deleted":              deleted ?? NSNull(),
                            "message":              message ?? NSNull(),
                            "messageType":          messageType ?? NSNull(),
                            "metadata":             metadata ?? NSNull(),
                            "repliedToMessageId":   repliedToMessageId ?? NSNull(),
                            "systemMetadata":       systemMetadata ?? NSNull(),
                            "time":                 time ?? NSNull()]
        return result
    }
	
	private enum CodingKeys: String ,CodingKey{
		case deleted  = "deleted"
		case message = "message"
		case messageType = "messageType"
		case metadata = "metadata"
		case repliedToMessageId = "repliedToMessageId"
		case systemMetadata = "systemMetadata"
		case repliedToMessageNanos = "repliedToMessageNanos"
		case repliedToMessageTime = "repliedToMessageTime"
		case participant = "participant"
		case time = "time"
	}
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.deleted  = try container.decodeIfPresent(Bool.self, forKey: .deleted)
		self.message  = try container.decodeIfPresent(String.self, forKey: .message)
		self.messageType  = try container.decodeIfPresent(Int.self, forKey: .messageType)
		self.metadata  = try container.decodeIfPresent(String.self, forKey: .metadata)
		self.repliedToMessageId  = try container.decodeIfPresent(Int.self, forKey: .repliedToMessageId)
		self.systemMetadata  = try container.decodeIfPresent(String.self, forKey: .systemMetadata)
		self.repliedToMessageNanos  = try container.decode(UInt.self, forKey: .repliedToMessageNanos)
		self.repliedToMessageTime =  try container.decode(UInt.self, forKey: .repliedToMessageTime)
		self.participant = try container.decode(Participant.self, forKey: .participant)
		guard let repliedToMessageTime = repliedToMessageTime , let repliedToMessageNanos = repliedToMessageNanos else {return}
		self.time = ((UInt(repliedToMessageTime / 1000)) * 1000000000 ) + repliedToMessageNanos
	}
    
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(deleted, forKey: .deleted)
		try container.encodeIfPresent(message, forKey: .message)
		try container.encodeIfPresent(messageType, forKey: .messageType)
		try container.encodeIfPresent(metadata, forKey: .metadata)
		try container.encodeIfPresent(repliedToMessageId, forKey: .repliedToMessageId)
		try container.encodeIfPresent(systemMetadata, forKey: .systemMetadata)
		try container.encodeIfPresent(time, forKey: .time)
		try container.encodeIfPresent(participant, forKey: .participant)
		
	}
}
