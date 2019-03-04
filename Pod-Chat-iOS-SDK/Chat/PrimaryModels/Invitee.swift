//
//  Invitee.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      Invitee        (formatDataToMakeInvitee)
//#######################################################################################

open class Invitee {
    /*
     * + InviteeVO       {object}
     *    - id           {string}
     *    - idType       {int}
     */
    
    public let id:     String?
    public var idType: Int?
    
    public init(messageContent: JSON) {
        
        self.id = messageContent["id"].string
        
        if let myIdType = messageContent["idType"].string {
            let type = myIdType
            if (type == "TO_BE_USER_SSO_ID") {
                self.idType = 1
            } else if (type == "TO_BE_USER_CONTACT_ID") {
                self.idType = 2
            } else if (type == "TO_BE_USER_CELLPHONE_NUMBER") {
                self.idType = 3
            } else if (type == "TO_BE_USER_USERNAME") {
                self.idType = 4
            }
        }
        
    }
    
    public init(id:     String?,
                idType: String?) {
        
        self.id = id
        if let myIdType = idType {
            if (myIdType == "TO_BE_USER_SSO_ID") {
                self.idType = 1
            } else if (myIdType == "TO_BE_USER_CONTACT_ID") {
                self.idType = 2
            } else if (myIdType == "TO_BE_USER_CELLPHONE_NUMBER") {
                self.idType = 3
            } else if (myIdType == "TO_BE_USER_USERNAME") {
                self.idType = 4
            }
        }
        
    }
    
    public init(theInvitee: Invitee) {
        
        self.id     = theInvitee.id
        self.idType = theInvitee.idType
        
    }
    
    public func formatDataToMakeInvitee() -> Invitee {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["id":               id ?? NSNull(),
                            "idType":           idType ?? NSNull()]
        return result
    }
    
}
