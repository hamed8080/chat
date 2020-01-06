//
//  SendInteractiveMessageRequestModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/23/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class SendInteractiveMessageRequestModel {
    
    public let content:         String
    public let messageId:       Int
    public let metadata:        JSON
    public let systemMetadata:  JSON?
    
    public let typeCode:        String?
    public let uniqueId:        String
    
    public init(content:        String,
                messageId:      Int,
                metadata:       JSON,
                systemMetadata: JSON?,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.content        = content
        self.messageId      = messageId
        self.metadata       = metadata
        self.systemMetadata = systemMetadata
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
}

