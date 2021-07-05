//
//  UNMuteCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class CallsHistoryRequest:BaseRequest{
    
    public let count             : Int
    public let offset            : Int
    public let callIds           : [Int]?
    public let type              : CallType?
    public let name              : String?
    public let creatorCoreUserId : Int?
    public let creatorSsoId      : Int?
    
    public init(count: Int = 50, offset: Int = 0 , callIds: [Int]? = nil, type: CallType? = nil, name: String? = nil, creatorCoreUserId: Int? = nil, creatorSsoId: Int? = nil) {
        self.count             = count
        self.offset            = offset
        self.callIds           = callIds
        self.type              = type
        self.name              = name
        self.creatorCoreUserId = creatorCoreUserId
        self.creatorSsoId      = creatorSsoId
    }
    
    private enum CodingKeys :String , CodingKey{
        case count              = "count"
        case offset             = "offset"
        case callIds            = "callIds"
        case type               = "type"
        case name               = "name"
        case creatorCoreUserId  = "creatorCoreUserId"
        case creatorSsoId       = "creatorSsoId"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
        try container.encode(offset, forKey: .offset)
        try container.encodeIfPresent(callIds, forKey: .callIds)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(creatorSsoId, forKey: .creatorSsoId)
        try container.encodeIfPresent(creatorCoreUserId, forKey: .creatorCoreUserId)
    }
    
}
