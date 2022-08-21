//
//  RemoveContactsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/12/21.
//

import Foundation
public class RemoveContactsRequest : BaseRequest{

    public let contactIds:  [Int]
    
    public init(contactIds:  [Int], uniqueId: String? = nil) {
        self.contactIds  = contactIds
        super.init(uniqueId: uniqueId)
    }
    
    private enum CodingKeys:String ,CodingKey{
        case contactIds = "id"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(contactIds, forKey: .contactIds)
    }
    
}
