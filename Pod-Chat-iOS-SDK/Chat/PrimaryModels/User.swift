//
//  User.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      User        (formatDataToMakeUser)
//#######################################################################################

open class User {
    /*
     * + User               User:
     *    - cellphoneNumber:    String?
     *    - email:              String?
     *    - id:                 Int?
     *    - image:              String?
     *    - lastSeen:           Int?
     *    - name:               String?
     *    - receiveEnable:      Bool?
     *    - sendEnable:         Bool?
     */
    
    public let cellphoneNumber:    String?
    public let email:              String?
    public let id:                 Int?
    public let image:              String?
    public let lastSeen:           Int?
    public let name:               String?
    public let receiveEnable:      Bool?
    public let sendEnable:         Bool?
    
    public init(messageContent: JSON) {
        
        self.cellphoneNumber    = messageContent["cellphoneNumber"].string
        self.email              = messageContent["email"].string
        self.id                 = messageContent["id"].int
        self.image              = messageContent["image"].string
        self.lastSeen           = messageContent["lastSeen"].int
        self.name               = messageContent["name"].string
        self.receiveEnable      = messageContent["receiveEnable"].bool
        self.sendEnable         = messageContent["sendEnable"].bool
        
    }
    
    public init(cellphoneNumber:   String?,
         email:             String?,
         id:                Int?,
         image:             String?,
         lastSeen:          Int?,
         name:              String?,
         receiveEnable:     Bool?,
         sendEnable:        Bool?) {
        
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.id                 = id
        self.image              = image
        self.lastSeen           = lastSeen
        self.name               = name
        self.receiveEnable      = receiveEnable
        self.sendEnable         = sendEnable
    }
    
    public init(theUser: User) {
        
        self.cellphoneNumber    = theUser.cellphoneNumber
        self.email              = theUser.email
        self.id                 = theUser.id
        self.image              = theUser.image
        self.lastSeen           = theUser.lastSeen
        self.name               = theUser.name
        self.receiveEnable      = theUser.receiveEnable
        self.sendEnable         = theUser.sendEnable
    }
    
    
    public func formatDataToMakeUser() -> User {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["id":               id ?? NSNull(),
                            "name":             name ?? NSNull(),
                            "email":            email ?? NSNull(),
                            "cellphoneNumber":  cellphoneNumber ?? NSNull(),
                            "image":            image ?? NSNull(),
                            "lastSeen":         lastSeen ?? NSNull(),
                            "sendEnable":       sendEnable ?? NSNull(),
                            "receiveEnable":    receiveEnable ?? NSNull()]
        return result
    }
    
}
