//
//  RemoveCallParticipantsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class RemoveCallParticipantsRequest:BaseRequest{
    
    let callId      : Int
    var userIds     : [Int]
    
    public init(callId: Int, userIds:[Int], uniqueId:String? = nil) {
        self.callId       = callId
        self.userIds      = userIds
        super.init(uniqueId: uniqueId)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        if userIds.count > 0 {
            try? container.encode(userIds)
        }
    }
    
}
