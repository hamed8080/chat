//
//  BlockedUser.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class BlockedContact {
    /*
     * + BlockedUser    BlockedUser:
     *    - id              Int
     *    - firstName       String
     *    - lastName        String
     *    - nickName        String
     */
    
    public var id:         Int?
    public var firstName:  String?
    public var lastName:   String?
    public var nickName:   String?
    
    public init(messageContent: JSON) {
        self.id         = messageContent["id"].int
        self.firstName  = messageContent["firstName"].string
        self.lastName   = messageContent["lastName"].string
        self.nickName   = messageContent["nickName"].string
    }
    
    public init(id:        Int?,
                firstName: String?,
                lastName:  String?,
                nickName:  String?) {
        
        self.id         = id
        self.firstName  = firstName
        self.lastName   = lastName
        self.nickName   = nickName
    }
    
    public init(theBlockedContact: BlockedContact) {
        
        self.id         = theBlockedContact.id
        self.firstName  = theBlockedContact.firstName
        self.lastName   = theBlockedContact.lastName
        self.nickName   = theBlockedContact.nickName
    }
    
    public func formatDataToMakeBlockedUser() -> BlockedContact {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["id":               id ?? NSNull(),
                            "firstName":        firstName ?? NSNull(),
                            "lastName":         lastName ?? NSNull(),
                            "nickName":         nickName ?? NSNull()]
        return result
    }
    
}


