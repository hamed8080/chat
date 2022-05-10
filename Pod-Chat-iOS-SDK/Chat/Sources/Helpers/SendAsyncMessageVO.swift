//
//  SendAsyncMessageVO.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation

public struct SendAsyncMessageVO : Encodable{
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
