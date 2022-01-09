//
//  NewGetHistoryRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/9/21.
//

import Foundation
public class NewGetHistoryRequest: BaseRequest {
    
    public let threadId         : Int
    public let offset           : Int
    public let count            : Int
    public let fromTime         : UInt?
    public let fromTimeNanos    : UInt?
    public let messageId        : Int?
    public let messageType      : Int?
    public let metadataCriteria : SearchMetadataCriteria?
    public let order            : String?
    public let query            : String?
    public let toTime           : UInt?
    public let hashtag          : String?
    public let toTimeNanos      : UInt?
    public let uniqueIds        : [String]?
    public let userId           : Int?
    public var messageThreadId  : Int?
    public var firstMessageId   : Int?
    public var lastMessageId    : Int?
    public var senderId         : Int?
    public var historyTime      : UInt?
    public var allMentioned     : Bool?
    public var unreadMentioned  : Bool?
    public var lastMessageTime  : UInt?
    public var historyEndTime   : UInt?
    
    public init(threadId         : Int,
                count            : Int?                     = nil ,
                fromTime         : UInt?                    = nil ,
                fromTimeNanos    : UInt?                    = nil ,
                messageId        : Int?                     = nil ,
                messageType      : Int?                     = nil ,
                metadataCriteria : SearchMetadataCriteria?  = nil ,
                offset           : Int?                     = nil ,
                order            : String?                  = nil ,
                query            : String?                  = nil ,
                toTime           : UInt?                    = nil ,
                toTimeNanos      : UInt?                    = nil ,
                uniqueIds        : [String]?                = nil ,
                userId           : Int?                     = nil ,
                hashtag          : String?                  = nil ,
                messageThreadId  : Int?                     = nil ,
                firstMessageId   : Int?                     = nil ,
                lastMessageId    : Int?                     = nil ,
                senderId         : Int?                     = nil ,
                historyTime      : UInt?                    = nil ,
                allMentioned     : Bool?                    = nil ,
                unreadMentioned  : Bool?                    = nil ,
                lastMessageTime  : UInt?                    = nil ,
                historyEndTime   : UInt?                    = nil ,
                uniqueId         : String?                  = nil ,
                typeCode         : String?                  = nil
    ) {
        self.threadId         = threadId
        self.count            = count ?? 50
        self.offset           = offset ?? 0
        self.fromTime         = fromTime
        self.fromTimeNanos    = fromTimeNanos
        self.messageId        = messageId
        self.messageType      = messageType
        self.metadataCriteria = metadataCriteria
        self.order            = order
        self.query            = query
        self.toTime           = toTime
        self.hashtag          = hashtag
        self.toTimeNanos      = toTimeNanos
        self.uniqueIds        = uniqueIds
        self.userId           = userId
        self.messageThreadId  = messageThreadId
        self.firstMessageId   = firstMessageId
        self.lastMessageId    = lastMessageId
        self.senderId         = senderId
        self.historyTime      = historyTime
        self.allMentioned     = allMentioned
        self.unreadMentioned  = unreadMentioned
        self.lastMessageTime  = lastMessageTime
        self.historyEndTime   = historyEndTime
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
    private enum CodingKeys : String , CodingKey{
        case count            = "count"
        case offset           = "offset"
        case fromTime         = "fromTime"
        case fromTimeNanos    = "fromTimeNanos"
        case messageId        = "id"
        case messageType      = "messageType"
        case metadataCriteria = "metadataCriteria"
        case order            = "order"
        case query            = "query"
        case toTime           = "toTime"
        case hashtag          = "hashtag"
        case toTimeNanos      = "toTimeNanos"
        case uniqueIds        = "uniqueIds"
        case userId           = "userId"
        case messageThreadId  = "messageThreadId"
        case firstMessageId   = "firstMessageId"
        case lastMessageId    = "lastMessageId"
        case senderId         = "senderId"
        case historyTime      = "historyTime"
        case allMentioned     = "allMentioned"
        case unreadMentioned  = "unreadMentioned"
        case lastMessageTime  = "lastMessageTime"
        case historyEndTime   = "historyEndTime"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count , forKey: .count)
        try container.encode(offset , forKey: .offset)
        try container.encodeIfPresent(fromTime , forKey: .fromTime)
        try container.encodeIfPresent(fromTimeNanos , forKey: .fromTimeNanos)
        try container.encodeIfPresent(toTime , forKey: .toTime)
        try container.encodeIfPresent(toTimeNanos , forKey: .toTimeNanos)
        try container.encodeIfPresent(order , forKey: .order)
        try container.encodeIfPresent(query , forKey: .query)
        try container.encodeIfPresent(messageId , forKey: .messageId)
        try container.encodeIfPresent(metadataCriteria , forKey: .metadataCriteria)
        try container.encodeIfPresent(uniqueIds, forKey: .uniqueIds)
        try container.encodeIfPresent(messageType, forKey: .messageType)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(hashtag, forKey: .hashtag)
        try container.encodeIfPresent(messageThreadId, forKey:.messageThreadId)
        try container.encodeIfPresent(firstMessageId, forKey:.firstMessageId)
        try container.encodeIfPresent(lastMessageId, forKey:.lastMessageId)
        try container.encodeIfPresent(senderId, forKey:.senderId)
        try container.encodeIfPresent(historyTime, forKey:.historyTime)
        try container.encodeIfPresent(allMentioned, forKey:.allMentioned)
        try container.encodeIfPresent(unreadMentioned, forKey:.unreadMentioned)
        try container.encodeIfPresent(lastMessageTime, forKey:.lastMessageTime)
        try container.encodeIfPresent(historyEndTime, forKey:.historyEndTime)
    }
}
