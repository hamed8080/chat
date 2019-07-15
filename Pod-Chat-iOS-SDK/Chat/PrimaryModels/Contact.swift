//
//  Contact.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class Contact {
    /*
     *  + ContactVO          Contact:
     *      - blocked           Bool?
     *      - cellphoneNumber   String?
     *      - email             String?
     *      - firstName         String?
     *      - hasUser           Bool?
     *      - id                Int?
     *      - image             String?
     *      - lastName          String?
     *      - linkedUser        LinkedUser?
     *      - notSeenDuration   Int?
     *      - timeStamp         UInt?
     *      - uniqueId          Bool?
     *      - userId            Int?
     */
    
    public let blocked:         Bool?
    public let cellphoneNumber: String?
    public let email:           String?
    public let firstName:       String?
    public var hasUser:         Bool     = false
    public let id:              Int?
    public let image:           String?
    public let lastName:        String?
    public var linkedUser:      LinkedUser?
    public let notSeenDuration: Int?
    public let timeStamp:       UInt?
    public let uniqueId:        String?
    public let userId:          Int?
    
    public init(messageContent: JSON) {
        self.blocked            = messageContent["blocked"].bool
        self.cellphoneNumber    = messageContent["cellphoneNumber"].string
        self.email              = messageContent["email"].string
        self.firstName          = messageContent["firstName"].string
        self.id                 = messageContent["id"].int
        self.image              = messageContent["profileImage"].string
        self.lastName           = messageContent["lastName"].string
        self.notSeenDuration    = messageContent["notSeenDuration"].int
        self.timeStamp          = messageContent["timeStamp"].uInt
        self.uniqueId           = messageContent["uniqueId"].string
        self.userId             = messageContent["userId"].int
        
        if (messageContent["hasUser"] != JSON.null) {
            self.hasUser = messageContent["hasUser"].boolValue
        }
        
        if (messageContent["linkedUser"] != JSON.null) {
            self.linkedUser = LinkedUser(messageContent: messageContent["linkedUser"])
        }
        
        //        if let tempLinkUser = messageContent["linkedUser"].array {
        //            self.linkedUser = LinkedUser(messageContent: tempLinkUser.first!)
        //        }
        
    }
    
    public init(blocked:            Bool?,
                cellphoneNumber:    String?,
                email:              String?,
                firstName:          String?,
                hasUser:            Bool,
                id:                 Int?,
                image:              String?,
                lastName:           String?,
                linkedUser:         LinkedUser?,
                notSeenDuration:    Int?,
                timeStamp:          UInt?,
                uniqueId:           String?,
                userId:             Int?) {
        
        self.blocked            = blocked
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.firstName          = firstName
        self.hasUser            = hasUser
        self.id                 = id
        self.image              = image
        self.lastName           = lastName
        self.linkedUser         = linkedUser
        self.notSeenDuration    = notSeenDuration
        self.timeStamp          = timeStamp
        self.uniqueId           = uniqueId
        self.userId             = userId
        
    }
    
    public init(theContact: Contact) {
        
        self.blocked            = theContact.blocked
        self.cellphoneNumber    = theContact.cellphoneNumber
        self.email              = theContact.email
        self.firstName          = theContact.firstName
        self.hasUser            = theContact.hasUser
        self.id                 = theContact.id
        self.image              = theContact.image
        self.lastName           = theContact.lastName
        self.linkedUser         = theContact.linkedUser
        self.notSeenDuration    = theContact.notSeenDuration
        self.timeStamp          = theContact.timeStamp
        self.uniqueId           = theContact.uniqueId
        self.userId             = theContact.userId
    }
    
    
    public func formatDataToMakeContact() -> Contact {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["blocked":          blocked ?? NSNull(),
                            "cellphoneNumber":  cellphoneNumber ?? NSNull(),
                            "email":            email ?? NSNull(),
                            "firstName":        firstName ?? NSNull(),
                            "hasUser":          hasUser,
                            "id":               id ?? NSNull(),
                            "image":            image ?? NSNull(),
                            "lastName":         lastName ?? NSNull(),
                            "linkedUser":       linkedUser?.formatToJSON() ?? NSNull(),
                            "notSeenDuration":  notSeenDuration ?? NSNull(),
                            "timeStamp":        timeStamp ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull(),
                            "userId":           userId ?? NSNull()]
        return result
    }
    
}
