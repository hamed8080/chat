//
//  LinkedUser.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class LinkedUser :Codable {
    /*
     * + RelatedUserVO  LinkedUser:
     *   - coreUserId:      Int?
     *   - image            String?
     *   - name             String?
     *   - nickname         String?
     *   - username         String?
     */
    
    public var coreUserId:  Int?
    public var image:       String?
    public var name:        String?
    public var nickname:    String?
    public var username:    String?
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(messageContent: JSON) {
        self.coreUserId = messageContent["coreUserId"].int ?? messageContent["id"].int
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
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(theLinkedUser: LinkedUser) {
        
        self.coreUserId = theLinkedUser.coreUserId
        self.image      = theLinkedUser.image
        self.name       = theLinkedUser.name
        self.nickname   = theLinkedUser.nickname
        self.username   = theLinkedUser.username
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatdataToMakeLinkedUser() -> LinkedUser {
        return self
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatToJSON() -> JSON {
        let result: JSON = ["coreUserId":   coreUserId ?? NSNull(),
                            "image":        image ?? NSNull(),
                            "name":         name ?? NSNull(),
                            "nickname":     nickname ?? NSNull(),
                            "username":     username ?? NSNull()]
        return result
    }
    
}
