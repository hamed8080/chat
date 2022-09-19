//
//  ContactResponse.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/12/21.
//

import Foundation
public class ContactResponse : Decodable{
    
    public var contentCount:       Int = 0
    public var contacts:           [Contact] = []
    
    private enum CodingKeys:String , CodingKey{
        case contacts     = "result"
        case contentCount = "count"
    }
    
    public required init(from decoder: Decoder) throws {
        let container     =  try  decoder.container(keyedBy: CodingKeys.self)
        contacts          = try container.decodeIfPresent([Contact].self, forKey: .contacts) ?? []
        contentCount      = try container.decodeIfPresent(Int.self, forKey: .contentCount) ?? 0
    }
}
