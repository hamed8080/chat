//
//  SendAsyncMessageVO.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import FanapPodAsyncSDK

public struct SendAsyncMessageVO : Encodable{
    public init(content: String, ttl: Int, peerName: String, priority: Int = 1, pushMsgType: AsyncMessageTypes? = nil) {
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
    var pushMsgType : AsyncMessageTypes?  = nil
    
    private enum CodingKeys:String, CodingKey{
        case content  = "content"
        case ttl      = "ttl"
        case peerName = "peerName"
        case priority = "priority"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(content, forKey: .content)
        try? container.encodeIfPresent(ttl, forKey: .ttl)
        try? container.encodeIfPresent(peerName, forKey: .peerName)
        try? container.encodeIfPresent(priority, forKey: .priority)
    }
}
