//
//  Conversation.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation


open class Conversation : Codable , Hashable{
    
    public static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var admin                            : Bool?
    public var canEditInfo                      : Bool?
    public var canSpam                          : Bool      = false
    public var closedThread                     : Bool      = false
    public var description                      : String?
    public var group                            : Bool?
    public var id                               : Int?
    public var image                            : String?
    public var joinDate                         : Int?
    public var lastMessage                      : String?
    public var lastParticipantImage             : String?
    public var lastParticipantName              : String?
    public var lastSeenMessageId                : Int?
    public var lastSeenMessageNanos             : UInt?
    public var lastSeenMessageTime              : UInt?
    public var mentioned                        : Bool?
    public var metadata                         : String?
    public var mute                             : Bool?
    public var participantCount                 : Int?
    public var partner                          : Int?
    public var partnerLastDeliveredMessageId    : Int?
    public var partnerLastDeliveredMessageNanos : UInt?
    public var partnerLastDeliveredMessageTime  : UInt?
    public var partnerLastSeenMessageId         : Int?
    public var partnerLastSeenMessageNanos      : UInt?
    public var partnerLastSeenMessageTime       : UInt?
    public var pin                              : Bool?
    public var time                             : UInt?
    public var title                            : String?
    public var type                             : Int?
    public var unreadCount                      : Int?
    public var uniqueName                       : String?
    public var userGroupHash                    : String?
    public var inviter                          : Participant?
    public var lastMessageVO                    : Message?
    public var participants                     : [Participant]?
    public var pinMessage                       : PinUnpinMessage?
    
    public init(admin                            : Bool?             = nil,
                canEditInfo                      : Bool?             = nil,
                canSpam                          : Bool?             = nil,
                closedThread                     : Bool?             = nil,
                description                      : String?           = nil,
                group                            : Bool?             = nil,
                id                               : Int?              = nil,
                image                            : String?           = nil,
                joinDate                         : Int?              = nil,
                lastMessage                      : String?           = nil,
                lastParticipantImage             : String?           = nil,
                lastParticipantName              : String?           = nil,
                lastSeenMessageId                : Int?              = nil,
                lastSeenMessageNanos             : UInt?             = nil,
                lastSeenMessageTime              : UInt?             = nil,
                mentioned                        : Bool?             = nil,
                metadata                         : String?           = nil,
                mute                             : Bool?             = nil,
                participantCount                 : Int?              = nil,
                partner                          : Int?              = nil,
                partnerLastDeliveredMessageId    : Int?              = nil,
                partnerLastDeliveredMessageNanos : UInt?             = nil,
                partnerLastDeliveredMessageTime  : UInt?             = nil,
                partnerLastSeenMessageId         : Int?              = nil,
                partnerLastSeenMessageNanos      : UInt?             = nil,
                partnerLastSeenMessageTime       : UInt?             = nil,
                pin                              : Bool?             = nil,
                time                             : UInt?             = nil,
                title                            : String?           = nil,
                type                             : Int?              = nil,
                unreadCount                      : Int?              = nil,
                uniqueName                       : String?           = nil,
                userGroupHash                    : String?           = nil,
                inviter                          : Participant?      = nil,
                lastMessageVO                    : Message?          = nil,
                participants                     : [Participant]?    = nil,
                pinMessage                       : PinUnpinMessage?  = nil) {
        
        self.admin                            = admin
        self.canEditInfo                      = canEditInfo
        self.canSpam                          = canSpam ?? false
        self.closedThread                     = closedThread ?? false
        self.description                      = description
        self.group                            = group
        self.id                               = id
        self.image                            = image
        self.joinDate                         = joinDate
        self.lastMessage                      = lastMessage
        self.lastParticipantImage             = lastParticipantImage
        self.lastParticipantName              = lastParticipantName
        self.lastSeenMessageId                = lastSeenMessageId
        self.lastSeenMessageNanos             = lastSeenMessageNanos
        self.lastSeenMessageTime              = lastSeenMessageTime
        self.mentioned                        = mentioned
        self.metadata                         = metadata
        self.mute                             = mute
        self.participantCount                 = participantCount
        self.partner                          = partner
        self.partnerLastDeliveredMessageId    = partnerLastDeliveredMessageId
        self.partnerLastDeliveredMessageNanos = partnerLastDeliveredMessageNanos
        self.partnerLastDeliveredMessageTime  = partnerLastDeliveredMessageTime
        self.partnerLastSeenMessageId         = partnerLastSeenMessageId
        self.partnerLastSeenMessageNanos      = partnerLastSeenMessageNanos
        self.partnerLastSeenMessageTime       = partnerLastSeenMessageTime
        self.pin                              = pin
        self.time                             = time
        self.title                            = title
        self.type                             = type
        self.unreadCount                      = unreadCount
        self.uniqueName                       = uniqueName
        self.userGroupHash                    = userGroupHash
        
        self.inviter                          = inviter
        self.lastMessageVO                    = lastMessageVO
        self.participants                     = participants
        self.pinMessage                       = pinMessage
    }
    
    public init(theConversation: Conversation) {
        
        self.admin          = theConversation.admin
        self.canEditInfo    = theConversation.canEditInfo
        self.canSpam        = theConversation.canSpam
        self.closedThread   = theConversation.closedThread
        self.description    = theConversation.description
        self.group          = theConversation.group
        self.id             = theConversation.id
        self.image          = theConversation.image
        self.joinDate       = theConversation.joinDate
        self.lastMessage    = theConversation.lastMessage
        self.lastParticipantImage   = theConversation.lastParticipantImage
        self.lastParticipantName    = theConversation.lastParticipantName
        self.lastSeenMessageId      = theConversation.lastSeenMessageId
        self.lastSeenMessageNanos   = theConversation.lastSeenMessageNanos
        self.lastSeenMessageTime    = theConversation.lastSeenMessageTime
        self.mentioned              = theConversation.mentioned
        self.metadata               = theConversation.metadata
        self.mute                   = theConversation.mute
        self.participantCount       = theConversation.participantCount
        self.partner                = theConversation.partner
        self.partnerLastDeliveredMessageId      = theConversation.partnerLastDeliveredMessageId
        self.partnerLastDeliveredMessageNanos   = theConversation.partnerLastDeliveredMessageNanos
        self.partnerLastDeliveredMessageTime    = theConversation.partnerLastDeliveredMessageTime
        self.partnerLastSeenMessageId       = theConversation.partnerLastSeenMessageId
        self.partnerLastSeenMessageNanos    = theConversation.partnerLastSeenMessageNanos
        self.partnerLastSeenMessageTime     = theConversation.partnerLastSeenMessageTime
        self.pin            = theConversation.pin
        self.time           = theConversation.time
        self.title          = theConversation.title
        self.type           = theConversation.type
        self.unreadCount    = theConversation.unreadCount
        self.uniqueName     = theConversation.uniqueName
        self.userGroupHash  = theConversation.userGroupHash
        
        self.inviter        = theConversation.inviter
        self.lastMessageVO  = theConversation.lastMessageVO
        self.participants   = theConversation.participants
        self.pinMessage     = theConversation.pinMessage
    }
	
	private enum CodingKeys: String ,CodingKey{
		case admin                            = "admin"
		case canEditInfo                      = "canEditInfo"
		case canSpam                          = "canSpam"
		case closedThread                     = "closedThread"
		case description                      = "description"
		case group                            = "group"
		case id                               = "id"
		case image                            = "image"
		case joinDate                         = "joinDate"
		case lastMessage                      = "lastMessage"
		case lastParticipantImage             = "lastParticipantImage"
		case lastParticipantName              = "lastParticipantName"
		case lastSeenMessageId                = "lastSeenMessageId"
		case lastSeenMessageNanos             = "lastSeenMessageNanos"
		case lastSeenMessageTime              = "lastSeenMessageTime"
		case mentioned                        = "mentioned"
		case metadata                         = "metadata"
		case mute                             = "mute"
		case participantCount                 = "participantCount"
		case partner                          = "partner"
		case partnerLastDeliveredMessageId    = "partnerLastDeliveredMessageId"
		case partnerLastDeliveredMessageNanos = "partnerLastDeliveredMessageNanos"
		case partnerLastDeliveredMessageTime  = "partnerLastDeliveredMessageTime"
		case partnerLastSeenMessageId         = "partnerLastSeenMessageId"
		case partnerLastSeenMessageNanos      = "partnerLastSeenMessageNanos"
		case partnerLastSeenMessageTime       = "partnerLastSeenMessageTime"
		case pin                              = "pin"
		case pinned                             = "pinned"
		case time                             = "time"
		case title                            = "title"
		case type                             = "type"
		case unreadCount                      = "unreadCount"
		case uniqueName                       = "uniqueName"
		case userGroupHash                    = "userGroupHash"
		case inviter                          = "inviter"
		case participants                     = "participants"
		case lastMessageVO                    = "lastMessageVO"
		case pinMessageVO                     = "pinMessageVO"
		case pinMessage = "pinMessage" // only in encode
	}
	
	public required init(from decoder: Decoder) throws {
        let container                         = try decoder.container(keyedBy: CodingKeys.self)
        self.admin                            = try container.decodeIfPresent(Bool.self, forKey: .admin)
        self.canEditInfo                      = try container.decodeIfPresent(Bool.self, forKey: .canEditInfo)
        self.canSpam                          = try container.decodeIfPresent(Bool.self, forKey: .canSpam) ?? false
        self.closedThread                     = try container.decodeIfPresent(Bool.self, forKey: .closedThread)  ?? false
        self.description                      = try container.decodeIfPresent(String.self, forKey: .description)
        self.group                            = try container.decodeIfPresent(Bool.self, forKey: .group)
        self.id                               = try container.decodeIfPresent(Int.self, forKey: .id)
        self.image                            = try container.decodeIfPresent(String.self, forKey: .image)
        self.joinDate                         = try container.decodeIfPresent(Int.self, forKey: .joinDate)
        self.lastMessage                      = try container.decodeIfPresent(String.self, forKey: .lastMessage)
        self.lastParticipantImage             = try container.decodeIfPresent(String.self, forKey: .lastParticipantImage)
        self.lastParticipantName              = try container.decodeIfPresent(String.self, forKey: .lastParticipantName)
        self.lastSeenMessageId                = try container.decodeIfPresent(Int.self, forKey: .lastSeenMessageId)
        self.lastSeenMessageNanos             = try container.decodeIfPresent(UInt.self, forKey: .lastSeenMessageNanos)
        self.lastSeenMessageTime              = try container.decodeIfPresent(UInt.self, forKey: .lastSeenMessageTime)
        self.mentioned                        = try container.decodeIfPresent(Bool.self, forKey: .mentioned)
        self.metadata                         = try container.decodeIfPresent(String.self, forKey: .metadata)
        self.mute                             = try container.decodeIfPresent(Bool.self, forKey: .mute)
        self.participantCount                 = try container.decodeIfPresent(Int.self, forKey: .participantCount)
        self.partner                          = try container.decodeIfPresent(Int.self, forKey: .partner)
        self.partnerLastDeliveredMessageId    = try container.decodeIfPresent(Int.self, forKey: .partnerLastSeenMessageId)
        self.partnerLastDeliveredMessageNanos = try container.decodeIfPresent(UInt.self, forKey: .partnerLastDeliveredMessageNanos)
        self.partnerLastDeliveredMessageTime  = try container.decodeIfPresent(UInt.self, forKey: .partnerLastDeliveredMessageTime)
        self.partnerLastSeenMessageId         = try container.decodeIfPresent(Int.self, forKey: .partnerLastSeenMessageId)
        self.partnerLastSeenMessageNanos      = try container.decodeIfPresent(UInt.self, forKey: .partnerLastSeenMessageNanos)
        self.partnerLastSeenMessageTime       = try container.decodeIfPresent(UInt.self, forKey: .partnerLastSeenMessageTime)
        self.pin                              = try container.decodeIfPresent(Bool.self, forKey: .pin) ?? container.decodeIfPresent(Bool.self, forKey: .pinned)
        self.time                             = try container.decodeIfPresent(UInt.self, forKey: .time)
        self.title                            = try container.decodeIfPresent(String.self, forKey: .title)
        self.type                             = try container.decodeIfPresent(Int.self, forKey: .type)
        self.unreadCount                      = try container.decodeIfPresent(Int.self, forKey: .unreadCount)
        self.uniqueName                       = try container.decodeIfPresent(String.self, forKey: .uniqueName)
        self.userGroupHash                    = try container.decodeIfPresent(String.self, forKey: .userGroupHash)
        self.inviter                          = try container.decodeIfPresent(Participant.self, forKey: .inviter)
        self.participants                     = try container.decodeIfPresent([Participant].self, forKey: .participants)
        self.lastMessageVO                    = try container.decodeIfPresent(Message.self, forKey: .lastMessageVO)
        self.pinMessage                       = try container.decodeIfPresent(PinUnpinMessage.self, forKey: .pinMessageVO)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(admin, forKey: .admin)
		try container.encodeIfPresent(canEditInfo, forKey: .canEditInfo)
		try container.encodeIfPresent(canSpam, forKey: .canSpam)
		try container.encodeIfPresent(closedThread, forKey: .closedThread)
		try container.encodeIfPresent(description, forKey: .description)
		try container.encodeIfPresent(group, forKey: .group)
		try container.encodeIfPresent(id, forKey: .id)
		try container.encodeIfPresent(image, forKey: .image)
		try container.encodeIfPresent(joinDate, forKey: .joinDate)
		try container.encodeIfPresent(lastMessage, forKey: .lastMessage)
		try container.encodeIfPresent(lastParticipantImage, forKey: .lastParticipantImage)
		try container.encodeIfPresent(lastParticipantName, forKey: .lastParticipantName)
		try container.encodeIfPresent(lastSeenMessageId, forKey: .lastSeenMessageId)
		try container.encodeIfPresent(lastSeenMessageNanos, forKey: .lastSeenMessageNanos)
		try container.encodeIfPresent(lastSeenMessageTime, forKey: .lastSeenMessageTime)
		try container.encodeIfPresent(mentioned, forKey: .mentioned)
		try container.encodeIfPresent(metadata, forKey: .metadata)
		try container.encodeIfPresent(mute, forKey: .mute)
		try container.encodeIfPresent(participantCount, forKey: .participantCount)
		try container.encodeIfPresent(partner, forKey: .partner)
		try container.encodeIfPresent(partnerLastDeliveredMessageId, forKey: .partnerLastDeliveredMessageId)
		try container.encodeIfPresent(partnerLastDeliveredMessageNanos, forKey: .partnerLastDeliveredMessageNanos)
		try container.encodeIfPresent(partnerLastDeliveredMessageTime, forKey: .partnerLastDeliveredMessageTime)
		try container.encodeIfPresent(partnerLastSeenMessageId, forKey: .partnerLastSeenMessageId)
		try container.encodeIfPresent(partnerLastSeenMessageNanos, forKey: .partnerLastSeenMessageNanos)
		try container.encodeIfPresent(partnerLastSeenMessageTime, forKey: .partnerLastSeenMessageTime)
		try container.encodeIfPresent(pin, forKey: .pin)
		try container.encodeIfPresent(time, forKey: .time)
		try container.encodeIfPresent(title, forKey: .title)
		try container.encodeIfPresent(type, forKey: .type)
		try container.encodeIfPresent(unreadCount, forKey: .unreadCount)
		try container.encodeIfPresent(uniqueName, forKey: .uniqueName)
		try container.encodeIfPresent(userGroupHash, forKey: .userGroupHash)
		try container.encodeIfPresent(inviter, forKey: .inviter)
		try container.encodeIfPresent(lastMessageVO, forKey: .lastMessageVO)
		try container.encodeIfPresent(participants, forKey: .participants)
		try container.encodeIfPresent(pinMessage, forKey: .pinMessage)
	}
    
}
