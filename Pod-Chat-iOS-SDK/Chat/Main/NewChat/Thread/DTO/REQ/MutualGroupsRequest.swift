//
//  MutualGroupsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/14/21.
//

import Foundation
public class MutualGroupsRequest: BaseRequest {
    
    internal let count      :Int
    internal let offset     :Int
    internal let toBeUserVO :Invitee
    
    public init (toBeUser:Invitee,count: Int = 50 , offset: Int = 0,uniqueId:String? = nil , typeCode:String? = nil){
        self.count      = count
        self.offset     = offset
        self.toBeUserVO = toBeUser
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
    private enum CodingKeys: String , CodingKey{
        case count          = "count"
        case offset         = "offset"
        case toBeUserVO     = "toBeUserVO"
        case idType         = "idType"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(count, forKey: .count)
        try? container.encodeIfPresent(offset, forKey: .offset)
        try? container.encodeIfPresent(toBeUserVO, forKey: .toBeUserVO)
    }
}
