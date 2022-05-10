//
//  SafeLeaveThreadRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/10/21.
//

import Foundation
public class SafeLeaveThreadRequest:LeaveThreadRequest{
    
    public let participantId : Int
    
    public init(threadId:Int , participantId:Int,clearHistory:Bool? = false ,uniqueId: String? = nil, typeCode: String? = nil) {
        self.participantId = participantId
        super.init(threadId: threadId, clearHistory: clearHistory, typeCode: typeCode, uniqueId: uniqueId)
    }
}
