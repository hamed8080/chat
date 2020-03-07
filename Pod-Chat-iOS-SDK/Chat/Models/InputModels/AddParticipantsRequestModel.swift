//
//  AddParticipantsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class AddParticipantsRequestModel {
    
    public let contactIds:  [Int]?   //
    public let usernames:   [String]?
    public let threadId:    Int     //
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(contactIds: [Int],
                threadId:   Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.contactIds = contactIds
        self.usernames  = nil
        self.threadId   = threadId
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public init(usernames:  [String],
                threadId:   Int,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.contactIds = nil
        self.usernames  = usernames
        self.threadId   = threadId
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    func convertContentToJSON() -> [JSON] {
        var content: [JSON] = []
        
        if let contacts = contactIds {
            for item in contacts {
                content.append(JSON(item))
            }
//            content = JSON(contacts)
        } else if let theUserNames = usernames {
            for username in theUserNames {
                var inviteeObjc: JSON = [:]
                inviteeObjc["id"] = JSON(username)
                inviteeObjc["idType"] = JSON(4)
                content.append(inviteeObjc)
            }
        }
        
        return content
    }
    
}

