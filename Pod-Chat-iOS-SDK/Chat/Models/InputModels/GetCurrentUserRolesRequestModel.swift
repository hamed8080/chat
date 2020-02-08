//
//  GetCurrentUserRolesRequestModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/8/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class GetCurrentUserRolesRequestModel {
    
    public let threadId:    Int
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(threadId:  Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.threadId   = threadId
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
}
