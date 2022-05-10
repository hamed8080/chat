//
//  ForwardMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/10/21.
//

import Foundation
public class ForwardMessageRequest: BaseRequest {
    
   
    public let messageIds   : [Int]
    public let threadId     : Int
    public let uniqueIds    : [String]
    
    public init(threadId:Int,
                messageIds:     [Int],
                typeCode:       String? = nil,
                uniqueId:       String? = nil
    ) {
        self.threadId       = threadId
        self.messageIds     = messageIds
        var uniqueIds : [String] = []
        for _ in messageIds {
            uniqueIds.append(UUID().uuidString)
        }
        self.uniqueIds = uniqueIds
        super.init(uniqueId: nil, typeCode: typeCode)
    }
    
    public init(threadId:Int,
                messageId:      Int,
                typeCode:       String? = nil,
                uniqueId:       String? = nil
    ) {
        self.threadId       = threadId
        self.messageIds     = [messageId]
        var uniqueIds : [String] = []
        for _ in messageIds {
            uniqueIds.append(UUID().uuidString)
        }
        self.uniqueIds = uniqueIds
        super.init(uniqueId: nil, typeCode: typeCode)
    }
    
}
