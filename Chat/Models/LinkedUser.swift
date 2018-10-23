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
     * + RelatedUserVO                 {object}
     *   - username                    {string}
     *   - nickname                    {string}
     *   - name                        {string}
     *   - image                       {string}
     */
    
    let username:   String?
    let nickname:   String?
    let name:       String?
    let image:      String?
    
    init(messageContent: JSON) {
        self.username   = messageContent["username"].string
        self.nickname   = messageContent["nickname"].string
        self.name       = messageContent["name"].string
        self.image      = messageContent["image"].string
    }
    
    func formatdataToMakeLinkedUser() -> LinkedUser {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["username":         username ?? NSNull(),
                            "nickname":         nickname ?? NSNull(),
                            "name":             name ?? NSNull(),
                            "image":            image ?? NSNull()]
        return result
    }
    
}
