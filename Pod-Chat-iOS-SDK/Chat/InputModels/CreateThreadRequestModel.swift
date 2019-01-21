//
//  CreateThreadRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class CreateThreadRequestModel {
    
    public let description:     String?
    public let image:           String?
    public let invitees:        [Invitee]
    public let metadata:        String?
    public let title:           String
    public let type:            String?
    public let uniqueId:        String?
    
    public init(description:    String?,
                image:          String?,
                invitees:       [Invitee],
                metadata:       String?,
                title:          String,
                type:           String?,
                uniqueId:       String?) {
        
        self.description    = description
        self.image          = image
        self.invitees   = invitees
        self.metadata       = metadata
        self.title          = title
        self.type       = type
        self.uniqueId   = uniqueId
    }
    
}

