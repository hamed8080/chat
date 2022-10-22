//
//  Message.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation

open class Message : Codable , Hashable {
    
    public static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var deletable      : Bool?
    public var delivered      : Bool?
    public var editable       : Bool?
    public var edited         : Bool?
    public var id             : Int?
    public var mentioned      : Bool?
    public var message        : String?
    public var messageType    : MessageType?
    public var metadata       : String?
    public var ownerId        : Int?
    public var pinned         : Bool?
    public var previousId     : Int?
    public var seen           : Bool?
    public var systemMetadata : String?
    public var threadId       : Int?
    public var time           : UInt?
    public var timeNanos      : UInt?
    public var uniqueId       : String?
    public var conversation   : Conversation?
    public var forwardInfo    : ForwardInfo?
    public var participant    : Participant?
    public var replyInfo      : ReplyInfo?
    
    public init(threadId:       Int? = nil,
                deletable:      Bool? = nil,
                delivered:      Bool? = nil,
                editable:       Bool? = nil,
                edited:         Bool? = nil,
                id:             Int? = nil,
                mentioned:      Bool? = nil,
                message:        String? = nil,
                messageType:    MessageType? = nil,
                metadata:       String? = nil,
                ownerId:        Int? = nil,
                pinned:         Bool? = nil,
                previousId:     Int? = nil,
                seen:           Bool? = nil,
                systemMetadata: String? = nil,
                time:           UInt? = nil,
                timeNanos:      UInt? = nil,
                uniqueId:       String? = nil,
                conversation:   Conversation? = nil,
                forwardInfo:    ForwardInfo? = nil,
                participant:    Participant? = nil,
                replyInfo:      ReplyInfo? = nil) {
        
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
		self.messageType  = try container.decodeIfPresent(MessageType.self, forKey: .messageType)
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
    
    init(chatMessage:ChatMessage){
        guard let data = chatMessage.content?.data(using: .utf8),let message = try? JSONDecoder().decode(Message.self, from: data) else{return}
        message.threadId    = chatMessage.subjectId
        self.threadId       = message.threadId
        self.deletable      = message.deletable
        self.delivered      = message.delivered
        self.editable       = message.editable
        self.edited         = message.edited
        self.id             = message.id
        self.mentioned      = message.mentioned
        self.message        = message.message
        self.messageType    = message.messageType
        self.metadata       = message.metadata
        self.ownerId        = message.participant?.id
        self.pinned         = message.pinned
        self.previousId     = message.previousId
        self.seen           = message.seen
        self.systemMetadata = message.systemMetadata
        self.time           = message.time
        self.timeNanos      = message.timeNanos
        self.uniqueId       = message.uniqueId
        self.conversation   = message.conversation
        self.forwardInfo    = message.forwardInfo
        self.participant    = message.participant
        self.replyInfo      = message.replyInfo
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
    
    //FIXME: need fix with object decoding in this calss with FileMetaData for proerty metadata
    public var metaData:FileMetaData?{
        guard let metadata = metadata?.data(using: .utf8),
              let metaData = try? JSONDecoder().decode(FileMetaData.self, from: metadata) else{return nil}
        return metaData
    }
}
