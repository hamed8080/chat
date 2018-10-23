//
//  BlockedUser.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

//#######################################################################################
//#############################      BlockedUser        (formatDataToMakeBlockedUser)
//#######################################################################################

class BlockedUser {
    /*
     * + BlockedUser              {object}
     *    - id                    {long}
     *    - firstName             {string}
     *    - lastName              {string}
     *    - nickName              {string}
     */
    
    let id:         Int?
    let firstName:  String?
    let lastName:   String?
    let nickName:   String?
    
    init(messageContent: JSON) {
        self.id         = messageContent["id"].int
        self.firstName  = messageContent["firstName"].string
        self.lastName   = messageContent["lastName"].string
        self.nickName   = messageContent["nickName"].string
    }
    
    func formatDataToMakeBlockedUser() -> BlockedUser {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["id":               id ?? NSNull(),
                            "firstName":        firstName ?? NSNull(),
                            "lastName":         lastName ?? NSNull(),
                            "nickName":         nickName ?? NSNull()]
        return result
    }
    
}


