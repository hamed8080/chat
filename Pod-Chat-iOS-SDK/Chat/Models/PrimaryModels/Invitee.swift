//
//  Invitee.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class Invitee {
    /*
     * + InviteeVO       {object}
     *    - id           {string}
     *    - idType       {int}
     */
    
    public var id:     String?
    public var idType: Int?
    
    public init(messageContent: JSON) {
        self.id = messageContent["id"].string
        if let myIdType = messageContent["idType"].string {
            switch myIdType {
            case InviteeVoIdTypes.TO_BE_USER_SSO_ID.stringValue():              self.idType = 1
            case InviteeVoIdTypes.TO_BE_USER_CONTACT_ID.stringValue():          self.idType = 2
            case InviteeVoIdTypes.TO_BE_USER_CELLPHONE_NUMBER.stringValue():    self.idType = 3
            case InviteeVoIdTypes.TO_BE_USER_USERNAME.stringValue():            self.idType = 4
            case InviteeVoIdTypes.TO_BE_USER_ID.stringValue():                  self.idType = 5
            default: break
            }
        } else if let myIdType = messageContent["idType"].int {
            self.idType = myIdType
        }
    }
    
    public init(id:     String?,
                idType: String?) {
        
        self.id = id
        if let myIdType = idType {
            switch myIdType {
            case InviteeVoIdTypes.TO_BE_USER_SSO_ID.stringValue(),
                 "\(InviteeVoIdTypes.TO_BE_USER_SSO_ID.intValue())":                self.idType = 1
                
            case InviteeVoIdTypes.TO_BE_USER_CONTACT_ID.stringValue(),
                 "\(InviteeVoIdTypes.TO_BE_USER_CONTACT_ID.stringValue())":         self.idType = 2
                
            case InviteeVoIdTypes.TO_BE_USER_CELLPHONE_NUMBER.stringValue(),
                 "\(InviteeVoIdTypes.TO_BE_USER_CELLPHONE_NUMBER.stringValue())":   self.idType = 3
                
            case InviteeVoIdTypes.TO_BE_USER_USERNAME.stringValue(),
                 "\(InviteeVoIdTypes.TO_BE_USER_USERNAME.stringValue())":           self.idType = 4
                
            case InviteeVoIdTypes.TO_BE_USER_ID.stringValue(),
                 "\(InviteeVoIdTypes.TO_BE_USER_ID.stringValue())":                 self.idType = 5
            default: break
            }
        }
        
    }
    
    public init(id:     String?,
                idType: InviteeVoIdTypes?) {
        
        self.id = id
        if let myIdType = idType {
            switch myIdType {
            case InviteeVoIdTypes.TO_BE_USER_SSO_ID:            self.idType = 1
            case InviteeVoIdTypes.TO_BE_USER_CONTACT_ID:        self.idType = 2
            case InviteeVoIdTypes.TO_BE_USER_CELLPHONE_NUMBER:  self.idType = 3
            case InviteeVoIdTypes.TO_BE_USER_USERNAME:          self.idType = 4
            case InviteeVoIdTypes.TO_BE_USER_ID:                self.idType = 5
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
