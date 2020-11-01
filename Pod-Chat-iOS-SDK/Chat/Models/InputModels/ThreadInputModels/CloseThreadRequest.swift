//
//  CloseThreadRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 8/11/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class CloseThreadRequest {
    
    public let threadId:    Int
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(threadId:   Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.threadId   = threadId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
}
