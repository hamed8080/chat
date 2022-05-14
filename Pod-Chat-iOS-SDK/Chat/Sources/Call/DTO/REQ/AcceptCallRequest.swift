//
//  AcceptCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class AcceptCallRequest:BaseRequest{
    
    let client     : SendClient
    let callId     : Int
    
    public init(callId:Int,client:SendClient,typeCode:String? = nil, uniqueId:String? = nil) {
        self.callId       = callId
        self.client       = client
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
}
