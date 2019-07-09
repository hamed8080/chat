//
//  LinkedUser.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class LinkedUser {
    /*
     * + RelatedUserVO  LinkedUser:
     *   - coreUserId:      Int?
     *   - image            String?
     *   - name             String?
     *   - nickname         String?
     *   - username         String?
     */
    
    public let coreUserId:  Int?
    public let image:       String?
    public let name:        String?
    public let nickname:    String?
    public let username:    String?
    
    
    public init(messageContent: JSON) {
//        self.coreUserId = messageContent["id"].int
        self.coreUserId = messageContent["coreUserId"].int
        self.image      = messageContent["image"].string
        self.name       = messageContent["name"].string
        self.nickname   = messageContent["nickname"].string
        self.username   = messageContent["username"].string
    }
    
    public init(coreUserId: Int?,
                image:      String?,
                name:       String?,
                nickname:   String?,
                username:   String?) {
        
        self.coreUserId = coreUserId
        self.image      = image
        self.name       = name
        self.nickname   = nickname
        self.username   = username
    }
    
    
    public init(theLinkedUser: LinkedUser) {
        
        self.coreUserId = theLinkedUser.coreUserId
        self.image      = theLinkedUser.image
        self.name       = theLinkedUser.name
        self.nickname   = theLinkedUser.nickname
        self.username   = theLinkedUser.username
    }
    
    public func formatdataToMakeLinkedUser() -> LinkedUser {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["coreUserId":   coreUserId ?? NSNull(),
                            "image":        image ?? NSNull(),
                            "name":         name ?? NSNull(),
                            "nickname":     nickname ?? NSNull(),
                            "username":     username ?? NSNull()]
        return result
    }
    
}
