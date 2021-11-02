//
//  RejectCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class RejectCallRequest:BaseRequest{
    
    let call : Call
    
    public init(call:Call, typeCode:String? = nil, uniqueId:String? = nil) {
        self.call      = call
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
    
}
