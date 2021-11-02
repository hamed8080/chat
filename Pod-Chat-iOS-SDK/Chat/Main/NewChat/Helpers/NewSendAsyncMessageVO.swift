//
//  NewSendAsyncMessageVO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

public struct NewSendAsyncMessageVO : Encodable{
    public init(content: String, ttl: Int, peerName: String, priority: Int = 1, pushMsgType: Int? = nil) {
        self.content = content
        self.ttl = ttl
        self.peerName = peerName
        self.priority = priority
        self.pushMsgType = pushMsgType
    }
    
	
    let content     : String
    let ttl         : Int
    let peerName    : String
    var priority    : Int   = 1
    var pushMsgType : Int?  = nil
}
