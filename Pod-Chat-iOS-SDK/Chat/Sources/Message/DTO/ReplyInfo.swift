//
//  ReplyInfo.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//
import Foundation

open class ReplyInfo : Codable {

    public var deleted               : Bool?
    public var repliedToMessageId    : Int?
    public var message               : String?
    public var messageType           : Int?
    public var metadata              : String?
    public var systemMetadata        : String?
    public var repliedToMessageTime  : UInt?  = nil
    public var repliedToMessageNanos : UInt?  = nil
    public var time                  : UInt?
    public var participant           : Participant?
    
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
		self.repliedToMessageNanos  = try container.decodeIfPresent(UInt.self, forKey: .repliedToMessageNanos)
		self.repliedToMessageTime =  try container.decodeIfPresent(UInt.self, forKey: .repliedToMessageTime)
		self.participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
        if let repliedToMessageTime = repliedToMessageTime , let repliedToMessageNanos = repliedToMessageNanos {
            self.time = ((UInt(repliedToMessageTime / 1000)) * 1000000000 ) + repliedToMessageNanos
        }
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
