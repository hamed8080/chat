//
//  GetJoinCallsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class GetJoinCallsRequest:BaseRequest{
   
    
    
    private let offset    : Int
    private let count     : Int
    private let name      : String?
    private let type      : CallType?
    private let threadIds : [Int]
    
    public init(threadIds : [Int],
                  offset    : Int        = 0,
                  count     : Int        = 50,
                  name      : String?    = nil,
                  type      : CallType?  = nil,
                  uniqueId  : String?    = nil) {
        self.offset    = offset
        self.count     = count
        self.name      = name
        self.type      = type
        self.threadIds = threadIds
        super.init(uniqueId: uniqueId)
    }
    
    
    private enum CodingKeys:String ,CodingKey{
        case offset    = "offset"
        case count     = "count"
        case name      = "name"
        case type      = "type"
        case threadIds = "threadIds"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(offset, forKey: .offset)
        try container.encodeIfPresent(count, forKey: .count)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(threadIds, forKey: .threadIds)
    }
}
