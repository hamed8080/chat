//
//  NewSendChatMessageVO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct NewSendChatMessageVO : Encodable {
    public init(type:               Int,
                token:              String,
                content:            String?     = nil,
                messageType:        Int?        = nil,
                metadata:           String?     = nil,
                repliedTo:          Int?        = nil,
                systemMetadata:     String?     = nil,
                subjectId:          Int?        = nil,
                tokenIssuer:        Int         = 1,
                typeCode:           String?     = nil,
                uniqueId:           String?     = nil
    ) {
        self.type               = type
        self.token              = token
        self.content            = content
        self.messageType        = messageType
        self.metadata           = metadata
        self.repliedTo          = repliedTo
        self.systemMetadata     = systemMetadata
        self.subjectId          = subjectId
        self.tokenIssuer        = tokenIssuer
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId
    }
    
    
	let type                         : Int
	let token                        : String
	var content                      : String?    = nil
	var messageType                  : Int?       = nil
	var metadata                     : String?    = nil
	var repliedTo                    : Int?       = nil
	var systemMetadata               : String?    = nil
	var subjectId                    : Int?       = nil
	var tokenIssuer                  : Int        = 1
	var typeCode                     : String?    = nil
	var uniqueId                     : String?    = nil
}
