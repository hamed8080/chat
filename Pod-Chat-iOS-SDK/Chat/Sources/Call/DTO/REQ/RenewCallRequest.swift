//
//  RenewCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class RenewCallRequest:BaseRequest{
    
    let invitess   : [Invitee]
    let callId     : Int
    
    public init(invitees: [Invitee], callId:Int, uniqueId:String? = nil) {
        self.invitess     = invitees
        self.callId       = callId
        super.init(uniqueId: uniqueId)
    }
}
