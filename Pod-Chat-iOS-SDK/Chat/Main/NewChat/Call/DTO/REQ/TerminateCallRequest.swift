//
//  TerminateCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class TerminateCallRequest:BaseRequest{
    
    let callId      : Int
    
    public init(callId: Int, typeCode:String? = nil, uniqueId:String? = nil) {
        self.callId       = callId
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
}
