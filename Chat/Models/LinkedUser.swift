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

class LinkedUser {
    /*
     * + RelatedUserVO  LinkedUser:
     *   - image            String?
     *   - name             String?
     *   - nickname         String?
     *   - username         String?
     */
    
    let image:      String?
    let name:       String?
    let nickname:   String?
    let username:   String?
    
    init(messageContent: JSON) {
        self.image      = messageContent["image"].string
        self.name       = messageContent["name"].string
        self.nickname   = messageContent["nickname"].string
        self.username   = messageContent["username"].string
    }
    
    func formatdataToMakeLinkedUser() -> LinkedUser {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["image":            image ?? NSNull(),
                            "name":             name ?? NSNull(),
                            "nickname":         nickname ?? NSNull(),
                            "username":         username ?? NSNull()]
        return result
    }
    
}
