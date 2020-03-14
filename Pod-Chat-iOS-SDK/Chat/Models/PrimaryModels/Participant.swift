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
    
    public var admin:               Bool?
    public var auditor:             Bool?
    public var blocked:             Bool?
    public var cellphoneNumber:     String?
    public var contactFirstName:    String?
    public var contactId:           Int?
    public var contactName:         String?
    public var contactLastName:     String?
    public var coreUserId:      Int?
    public var email:           String?
    public var firstName:       String?
    public var id:              Int?
    public var image:           String?
    public var keyId:           String?
    public var lastName:        String?
    public var myFriend:        Bool?
    public var name:            String?
    public var notSeenDuration: Int?
    public var online:          Bool?
    public var receiveEnable:   Bool?
    public var roles:           [String]?
    public var sendEnable:      Bool?
    public var username:        String?
    
    public init(messageContent: JSON, threadId: Int?) {
        self.admin              = messageContent["admin"].bool
        self.auditor            = messageContent["auditor"].bool
        self.blocked            = messageContent["blocked"].bool
        self.cellphoneNumber    = messageContent["cellphoneNumber"].string
        self.contactFirstName   = messageContent["contactFirstName"].string
        self.contactId          = messageContent["contactId"].int
        self.contactName        = messageContent["contactName"].string
        self.contactLastName    = messageContent["contactLastName"].string
        self.coreUserId         = messageContent["coreUserId"].int
        self.email              = messageContent["email"].string
        self.firstName          = messageContent["firstName"].string
        self.id                 = messageContent["id"].int //?? ( (messageContent["id"].string != nil) ? Int(messageContent["id"].stringValue) : nil )
        self.image              = messageContent["image"].string
        self.keyId              = messageContent["keyId"].string
        self.lastName           = messageContent["lastName"].string
        self.myFriend           = messageContent["myFriend"].bool
        self.name               = messageContent["name"].string
        self.notSeenDuration    = messageContent["notSeenDuration"].int
        self.online             = messageContent["online"].bool
        self.receiveEnable      = messageContent["receiveEnable"].bool
        self.sendEnable         = messageContent["sendEnable"].bool
        self.username           = messageContent["username"].string
        
        var adminRoles = [String]()
        if let myRoles = messageContent["roles"].arrayObject as! [String]? {
            for role in myRoles {
                adminRoles.append(role)
            }
        }
        if (adminRoles.count > 0) {
            self.roles = adminRoles
        }
//         ?  : (self.roles = nil)
        
    }
    
    public init(admin:              Bool?,
                auditor:            Bool?,
                blocked:            Bool?,
                cellphoneNumber:    String?,
                contactFirstName:   String?,
                contactId:          Int?,
                contactName:        String?,
                contactLastName:    String?,
                coreUserId:         Int?,
                email:              String?,
                firstName:          String?,
                id:                 Int?,
                image:              String?,
                keyId:              String?,
                lastName:           String?,
                myFriend:           Bool?,
                name:               String?,
                notSeenDuration:    Int?,
                online:             Bool?,
                receiveEnable:      Bool?,
                roles:              [String]?,
                sendEnable:         Bool?,
                username:           String?) {
        
        self.admin              = admin
        self.auditor            = auditor
        self.blocked            = blocked
        self.cellphoneNumber    = cellphoneNumber
        self.contactFirstName   = contactFirstName
        self.contactId          = contactId
        self.contactName        = contactName
        self.contactLastName    = contactLastName
        self.coreUserId         = coreUserId
        self.email              = email
        self.firstName          = firstName
        self.id                 = id
        self.image              = image
        self.keyId              = keyId
        self.lastName           = lastName
        self.myFriend           = myFriend
        self.name               = name
        self.notSeenDuration    = notSeenDuration
        self.online             = online
        self.receiveEnable      = receiveEnable
        self.roles              = roles
        self.sendEnable         = sendEnable
        self.username           = username
    }
    
    public init(theParticipant: Participant) {
        
        self.admin              = theParticipant.admin
        self.auditor            = theParticipant.auditor
        self.blocked            = theParticipant.blocked
        self.cellphoneNumber    = theParticipant.cellphoneNumber
        self.contactFirstName   = theParticipant.contactFirstName
        self.contactId          = theParticipant.contactId
        self.contactName        = theParticipant.contactName
        self.contactLastName    = theParticipant.contactLastName
        self.coreUserId         = theParticipant.coreUserId
        self.email              = theParticipant.email
        self.firstName          = theParticipant.firstName
        self.id                 = theParticipant.id
        self.image              = theParticipant.image
        self.keyId              = theParticipant.keyId
        self.lastName           = theParticipant.lastName
        self.myFriend           = theParticipant.myFriend
        self.name               = theParticipant.name
        self.notSeenDuration    = theParticipant.notSeenDuration
        self.online             = theParticipant.online
        self.receiveEnable      = theParticipant.receiveEnable
        self.roles              = theParticipant.roles
        self.sendEnable         = theParticipant.sendEnable
        self.username           = theParticipant.username
    }
    
    
    public func formatDataToMakeParticipant() -> Participant {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["admin":            admin ?? NSNull(),
                            "auditor":          auditor ?? NSNull(),
                            "blocked":          blocked ?? NSNull(),
                            "cellphoneNumber":  cellphoneNumber ?? NSNull(),
                            "contactFirstName": contactFirstName ?? NSNull(),
                            "contactId":        contactId ?? NSNull(),
                            "contactName":      contactName ?? NSNull(),
                            "contactLastName":  contactLastName ?? NSNull(),
                            "coreUserId":       coreUserId ?? NSNull(),
                            "email":            email ?? NSNull(),
                            "firstName":        firstName ?? NSNull(),
                            "id":               id ?? NSNull(),
                            "image":            image ?? NSNull(),
                            "keyId":            keyId ?? NSNull(),
                            "lastName":         lastName ?? NSNull(),
                            "myFriend":         myFriend ?? NSNull(),
                            "name":             name ?? NSNull(),
                            "notSeenDuration":  notSeenDuration ?? NSNull(),
                            "online":           online ?? NSNull(),
                            "receiveEnable":    receiveEnable ?? NSNull(),
                            "roles":            roles ?? NSNull(),
                            "sendEnable":       sendEnable ?? NSNull(),
                            "username":         username ?? NSNull()]
        return result
    }
    
}
