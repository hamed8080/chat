//
//  LinkedUser.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      LinkedUser        (formatdataToMakeLinkedUser)
//#######################################################################################

open class LinkedUser {
    /*
     * + RelatedUserVO  LinkedUser:
     *   - image            String?
     *   - name             String?
     *   - nickname         String?
     *   - username         String?
     */
    
    public let id:          Int?
    public let image:       String?
    public let name:        String?
    public let nickname:    String?
    public let username:    String?
    
    
    public init(messageContent: JSON) {
        self.id         = messageContent["id"].int
        self.image      = messageContent["image"].string
        self.name       = messageContent["name"].string
        self.nickname   = messageContent["nickname"].string
        self.username   = messageContent["username"].string
    }
    
    public init(id:        Int?,
                image:     String?,
                name:      String?,
                nickname:  String?,
                username:  String?) {
        
        self.id         = id
        self.image      = image
        self.name       = name
        self.nickname   = nickname
        self.username   = username
    }
    
    
    public init(theLinkedUser: LinkedUser) {
        
        self.id         = theLinkedUser.id
        self.image      = theLinkedUser.image
        self.name       = theLinkedUser.name
        self.nickname   = theLinkedUser.nickname
        self.username   = theLinkedUser.username
    }
    
    public func formatdataToMakeLinkedUser() -> LinkedUser {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["id":               id ?? NSNull(),
                            "image":            image ?? NSNull(),
                            "name":             name ?? NSNull(),
                            "nickname":         nickname ?? NSNull(),
                            "username":         username ?? NSNull()]
        return result
    }
    
}
