//
//  UNMuteCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class UNMuteCallRequest:BaseRequest{
    
    let callId     : Int
    let userIds    : [Int]
    
    public init(callId: Int,userIds:[Int], uniqueId:String? = nil) {
        self.callId     = callId
        self.userIds    = userIds
        super.init(uniqueId: uniqueId)
    }

}
