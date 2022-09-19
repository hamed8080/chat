//
//  RemoveContactResponse.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation
public class RemoveContactResponse:Decodable {
    
    public var deteled:  Bool
    
    private enum CodingKeys : String ,CodingKey{
        case result       = "result"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.deteled = try container.decodeIfPresent(Bool.self, forKey: .result) ?? false
    }
}
