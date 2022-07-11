//
//  EndCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class EndCallRequest:BaseRequest{
    
    let callId   :Int
    
    public init(callId: Int, uniqueId:String? = nil) {
        self.callId     = callId
        super.init(uniqueId: uniqueId)
    }

}
