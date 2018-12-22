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

open class BlockedContact {
    /*
     * + BlockedUser    BlockedUser:
     *    - id              Int
     *    - firstName       String
     *    - lastName        String
     *    - nickName        String
     */
    
    public let id:         Int?
    public let firstName:  String?
    public let lastName:   String?
    public let nickName:   String?
    
    init(messageContent: JSON) {
        self.id         = messageContent["id"].int
        self.firstName  = messageContent["firstName"].string
        self.lastName   = messageContent["lastName"].string
        self.nickName   = messageContent["nickName"].string
    }
    
    func formatDataToMakeBlockedUser() -> BlockedContact {
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


