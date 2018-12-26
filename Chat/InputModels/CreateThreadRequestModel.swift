//
//  CreateThreadRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class CreateThreadRequestModel {
    
    public let title:               String
    public let type:                String?
    public let invitees:            [Invitee]
    public let uniqueId:            String?
    
    public init(title:     String,
                type:      String?,
                invitees:  [Invitee],
                uniqueId:  String?) {
        
        self.title      = title
        self.type       = type
        self.invitees   = invitees
        self.uniqueId   = uniqueId
    }
    
}

