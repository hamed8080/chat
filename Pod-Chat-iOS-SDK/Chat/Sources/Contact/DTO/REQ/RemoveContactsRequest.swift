//
//  RemoveContactsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/12/21.
//

import Foundation
public class RemoveContactsRequest : BaseRequest{

    public let contactId:   Int
    public init(contactId:  Int, uniqueId: String? = nil) {
        
        self.contactId  = contactId
        super.init(uniqueId: nil)
    }
    
    private enum CodingKeys:String ,CodingKey{
        case contactId = "id"
        case typeCode  = "typeCode"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(contactId, forKey: .contactId)
        try? container.encodeIfPresent(Chat.sharedInstance.config?.typeCode, forKey: .typeCode)
    }
    
}
