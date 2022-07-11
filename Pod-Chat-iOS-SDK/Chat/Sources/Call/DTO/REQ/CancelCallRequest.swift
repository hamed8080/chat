//
//  CancelCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class CancelCallRequest:BaseRequest{
    
    let call : Call
    
    public init(call:Call, uniqueId:String? = nil) {
        self.call      = call
        super.init(uniqueId: uniqueId)
    }
    
}
