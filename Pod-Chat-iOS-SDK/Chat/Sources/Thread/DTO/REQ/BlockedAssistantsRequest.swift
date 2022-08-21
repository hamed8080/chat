//
//  BlockedAssistantsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/13/21.
//

import Foundation
public class BlockedAssistantsRequest: BaseRequest {
    
    internal let count  :Int
    internal let offset :Int
    
    public init (count: Int = 50 , offset: Int = 0,uniqueId:String? = nil){
        self.count      = count
        self.offset     = offset
        super.init(uniqueId: uniqueId)
    }
    
    private enum CodingKeys: String , CodingKey{
        case count  = "count"
        case offset = "offset"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(count, forKey: .count)
        try? container.encodeIfPresent(offset, forKey: .offset)
    }
}
