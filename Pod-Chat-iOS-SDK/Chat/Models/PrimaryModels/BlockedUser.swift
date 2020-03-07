//
//  BlockedUser.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class BlockedUser {
    
    public var id:          Int?
    public var coreUserId:  Int?
    public var firstName:   String?
    public var lastName:    String?
    public var nickName:    String?
    public var profileImage: String?
    public var contact:     Contact?
    
    public init(messageContent: JSON) {
        self.id             = messageContent["id"].int
        self.coreUserId     = messageContent["coreUserId"].int
        self.firstName      = messageContent["firstName"].string
        self.lastName       = messageContent["lastName"].string
        self.nickName       = messageContent["nickName"].string
        self.profileImage   = messageContent["profileImage"].string
        self.contact        = Contact(messageContent: messageContent["contactVO"])
    }
    
    public init(id:         Int?,
                coreUserId: Int?,
                firstName:  String?,
                lastName:   String?,
                nickName:   String?,
                profileImage: String?,
                contact:    Contact?) {
        
        self.id             = id
        self.coreUserId     = coreUserId
        self.firstName      = firstName
        self.lastName       = lastName
        self.nickName       = nickName
        self.profileImage   = profileImage
        self.contact        = contact
    }
    
    public init(theBlockedContact: BlockedUser) {
        
        self.id             = theBlockedContact.id
        self.coreUserId     = theBlockedContact.coreUserId
        self.firstName      = theBlockedContact.firstName
        self.lastName       = theBlockedContact.lastName
        self.nickName       = theBlockedContact.nickName
        self.profileImage   = theBlockedContact.profileImage
        self.contact        = theBlockedContact.contact
    }
    
    public func formatDataToMakeBlockedUser() -> BlockedUser {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["id":               id ?? NSNull(),
                            "coreUserId":   coreUserId ?? NSNull(),
                            "firstName":    firstName ?? NSNull(),
                            "lastName":     lastName ?? NSNull(),
                            "nickName":     nickName ?? NSNull(),
                            "profileImage": profileImage ?? NSNull(),
                            "contact":      contact?.formatToJSON() ?? NSNull()]
        return result
    }
    
}


