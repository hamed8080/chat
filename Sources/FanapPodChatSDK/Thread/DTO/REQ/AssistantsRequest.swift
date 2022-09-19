//
//  AssistantsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/6/21.
//

import Foundation

public class AssistantsRequest : BaseRequest{
    
    public let contactType: String
    public let count:       Int
    public let offset:      Int
    
    public init(contactType : String,
                count       : Int       = 50,
                offset      : Int       = 0,
                uniqueId    : String?   = nil
    ) {
        self.contactType                     = contactType
        self.count                           = count
        self.offset                          = offset
        super.init(uniqueId: uniqueId)
       
    }
    
    
    private enum CodingKeys:String , CodingKey{
        case contactType = "contactType"
        case count       = "count"
        case offset      = "offset"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(contactType, forKey: .contactType)
        try container.encodeIfPresent(count, forKey: .count)
        try container.encodeIfPresent(offset, forKey: .offset)
    }
}
