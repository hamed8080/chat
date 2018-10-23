//
//  User.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      User        (formatDataToMakeUser)
//#######################################################################################

class User {
    /*
     * + User               User
     *    - id                  Int
     *    - name                String
     *    - email               String
     *    - cellphoneNumber     String
     *    - image               String
     *    - lastSeen            Int
     *    - sendEnable          Bool
     *    - receiveEnable       Bool
     */
    
    let id:                 Int?
    let name:               String?
    let email:              String?
    let cellphoneNumber:    String?
    let image:              String?
    let lastSeen:           Int?
    let sendEnable:         Bool?
    let receiveEnable:      Bool?
    
    init(messageContent: JSON) {
        
        self.id                 = messageContent["id"].int
        self.name               = messageContent["name"].string
        self.email              = messageContent["email"].string
        self.cellphoneNumber    = messageContent["cellphoneNumber"].string
        self.image              = messageContent["image"].string
        self.lastSeen           = messageContent["lastSeen"].int
        self.sendEnable         = messageContent["sendEnable"].bool
        self.receiveEnable      = messageContent["receiveEnable"].bool
        
    }
    
    func formatDataToMakeUser() -> User {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["id":               id ?? NSNull(),
                            "name":             name ?? NSNull(),
                            "email":            email ?? NSNull(),
                            "cellphoneNumber":  cellphoneNumber ?? NSNull(),
                            "image":            image ?? NSNull(),
                            "lastSeen":         lastSeen ?? NSNull(),
                            "sendEnable":       sendEnable ?? NSNull(),
                            "receiveEnable":    receiveEnable ?? NSNull()]
        return result
    }
    
}
