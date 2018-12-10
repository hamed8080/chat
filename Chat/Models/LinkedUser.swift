//
//  LinkedUser.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      LinkedUser        (formatdataToMakeLinkedUser)
//#######################################################################################

open class LinkedUser {
    /*
     * + RelatedUserVO  LinkedUser:
     *   - image            String?
     *   - name             String?
     *   - nickname         String?
     *   - username         String?
     */
    
    public let coreUserId:  Int?
    public let image:       String?
    public let name:        String?
    public let nickname:    String?
    public let username:    String?
    
    init(messageContent: JSON) {
        self.coreUserId = messageContent["coreUserId"].int
        self.image      = messageContent["image"].string
        self.name       = messageContent["name"].string
        self.nickname   = messageContent["nickname"].string
        self.username   = messageContent["username"].string
    }
    
    func formatdataToMakeLinkedUser() -> LinkedUser {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["coreUserId":       coreUserId ?? NSNull(),
                            "image":            image ?? NSNull(),
                            "name":             name ?? NSNull(),
                            "nickname":         nickname ?? NSNull(),
                            "username":         username ?? NSNull()]
        return result
    }
    
}
