//
//  AddRemoveAuditorRequestModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/24/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AddRemoveAuditorRequest {
    
    public var roles:       [Roles] = []
    public let threadId:    Int
    public let userId:      Int
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(roles:      [Roles],
                threadId:   Int,
                userId:     Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.roles      = roles
        self.threadId   = threadId
        self.userId     = userId
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
}


/// MARK: -  this class will be deprecate (use this class instead: 'AddRemoveAuditorRequest')
open class AddRemoveAuditorRequestModel: AddRemoveAuditorRequest {
    
}
