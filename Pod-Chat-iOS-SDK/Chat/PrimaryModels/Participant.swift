//
//  Participant.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class Participant {
    /*
     * + ParticipantVO      Participant:
     *    - cellphoneNumber:    String?
     *    - contactId:          Int?
     *    - email:              String?
     *    - firstName:          String?
     *    - id:                 Int?
     *    - image:              String?
     *    - lastName:           String?
     *    - myFriend:           Bool?
     *    - name:               String?
     *    - notSeenDuration:    Int?
     *    - online:             Bool?
     *    - receiveEnable:      Bool?
     *    - sendEnable:         Bool?
     */
    
    public let admin:           Bool?
    public let blocked:         Bool?
    public let cellphoneNumber: String?
    public let contactId:       Int?
    public let coreUserId:      Int?
    public let email:           String?
    public let firstName:       String?
    public let id:              Int?
    public let image:           String?
    public let lastName:        String?
    public let myFriend:        Bool?
    public let name:            String?
    public let notSeenDuration: Int?
    public let online:          Bool?
    public let receiveEnable:   Bool?
    public let roles:           [String]?
    public let sendEnable:      Bool?
    
    public init(messageContent: JSON, threadId: Int?) {
        self.admin              = messageContent["admin"].bool
        self.blocked            = messageContent["blocked"].bool
        self.cellphoneNumber    = messageContent["cellphoneNumber"].string
        self.contactId          = messageContent["contactId"].int
        self.coreUserId         = messageContent["coreUserId"].int
        self.email              = messageContent["email"].string
        self.firstName          = messageContent["firstName"].string
        self.id                 = messageContent["id"].int
        self.image              = messageContent["image"].string
        self.lastName           = messageContent["lastName"].string
        self.myFriend           = messageContent["myFriend"].bool
        self.name               = messageContent["name"].string
        self.notSeenDuration    = messageContent["notSeenDuration"].int
        self.online             = messageContent["online"].bool
        self.receiveEnable      = messageContent["receiveEnable"].bool
        
        var adminRoles = [String]()
        if let myRoles = messageContent["roles"].arrayObject as! [String]? {
            for role in myRoles {
                adminRoles.append(role)
            }
        }
        (adminRoles.count > 0) ? (self.roles = adminRoles) : (self.roles = nil)
        
        self.sendEnable         = messageContent["sendEnable"].bool
    }
    
    public init(admin:              Bool?,
                blocked:            Bool?,
                cellphoneNumber:    String?,
                contactId:          Int?,
                coreUserId:         Int?,
                email:              String?,
                firstName:          String?,
                id:                 Int?,
                image:              String?,
                lastName:           String?,
                myFriend:           Bool?,
                name:               String?,
                notSeenDuration:    Int?,
                online:             Bool?,
                receiveEnable:      Bool?,
                roles:              [String]?,
                sendEnable:         Bool?) {
        
        self.admin              = admin
        self.blocked            = blocked
        self.cellphoneNumber    = cellphoneNumber
        self.contactId          = contactId
        self.coreUserId         = coreUserId
        self.email              = email
        self.firstName          = firstName
        self.id                 = id
        self.image              = image
        self.lastName           = lastName
        self.myFriend           = myFriend
        self.name               = name
        self.notSeenDuration    = notSeenDuration
        self.online             = online
        self.receiveEnable      = receiveEnable
        self.roles              = roles
        self.sendEnable         = sendEnable
    }
    
    public init(theParticipant: Participant) {
        
        self.admin              = theParticipant.admin
        self.blocked            = theParticipant.blocked
        self.cellphoneNumber    = theParticipant.cellphoneNumber
        self.contactId          = theParticipant.contactId
        self.coreUserId         = theParticipant.coreUserId
        self.email              = theParticipant.email
        self.firstName          = theParticipant.firstName
        self.id                 = theParticipant.id
        self.image              = theParticipant.image
        self.lastName           = theParticipant.lastName
        self.myFriend           = theParticipant.myFriend
        self.name               = theParticipant.name
        self.notSeenDuration    = theParticipant.notSeenDuration
        self.online             = theParticipant.online
        self.receiveEnable      = theParticipant.receiveEnable
        self.roles              = theParticipant.roles
        self.sendEnable         = theParticipant.sendEnable
    }
    
    
    public func formatDataToMakeParticipant() -> Participant {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["admin":            admin ?? NSNull(),
                            "blocked":          blocked ?? NSNull(),
                            "cellphoneNumber":  cellphoneNumber ?? NSNull(),
                            "contactId":        contactId ?? NSNull(),
                            "coreUserId":       coreUserId ?? NSNull(),
                            "email":            email ?? NSNull(),
                            "firstName":        firstName ?? NSNull(),
                            "id":               id ?? NSNull(),
                            "image":            image ?? NSNull(),
                            "lastName":         lastName ?? NSNull(),
                            "myFriend":         myFriend ?? NSNull(),
                            "name":             name ?? NSNull(),
                            "notSeenDuration":  notSeenDuration ?? NSNull(),
                            "online":           online ?? NSNull(),
                            "receiveEnable":    receiveEnable ?? NSNull(),
                            "roles":            roles ?? NSNull(),
                            "sendEnable":       sendEnable ?? NSNull()]
        return result
    }
    
}
