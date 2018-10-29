//
//  Contact.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      Contact        (formatDataToMakeContact)
//#######################################################################################

class Contact {
    /*
     * + ContactVO          Contact:
     *    - cellphoneNumber     String?
     *    - email               String?
     *    - firstName           String?
     *    - hasUser             Bool?
     *    - id                  Int?
     *    - image               String?
     *    - lastName            String?
     *    - linkedUser          LinkedUser?
     *    - notSeenDuration     Int?
     *    - uniqueId            Bool?
     *    - userId              Int?
     */
    
    let cellphoneNumber:    String?
    let email:              String?
    let firstName:          String?
    let hasUser:            Bool?
    let id:                 Int?
    let image:              String?
    let lastName:           String?
    var linkedUser:         LinkedUser?
    let notSeenDuration:    Int?
    let uniqueId:           String?
    let userId:             Int?
    
    init(messageContent: JSON) {
        self.cellphoneNumber    = messageContent["cellphoneNumber"].string
        self.email              = messageContent["email"].string
        self.firstName          = messageContent["firstName"].string
        self.hasUser            = messageContent["hasUser"].bool
        self.id                 = messageContent["id"].int
        self.image              = messageContent["profileImage"].string
        self.lastName           = messageContent["lastName"].string
        self.notSeenDuration    = messageContent["notSeenDuration"].int
        self.uniqueId           = messageContent["uniqueId"].string
        self.userId             = messageContent["userId"].int
        
        if (messageContent["linkedUser"] != JSON.null) {
            self.linkedUser = LinkedUser(messageContent: messageContent["linkedUser"])
        }
        
        //        if let tempLinkUser = messageContent["linkedUser"].array {
        //            self.linkedUser = LinkedUser(messageContent: tempLinkUser.first!)
        //        }
        
    }
    
    func formatDataToMakeContact() -> Contact {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["cellphoneNumber":  cellphoneNumber ?? NSNull(),
                            "email":            email ?? NSNull(),
                            "firstName":        firstName ?? NSNull(),
                            "hasUser":          hasUser ?? NSNull(),
                            "id":               id ?? NSNull(),
                            "image":            image ?? NSNull(),
                            "lastName":         lastName ?? NSNull(),
                            "linkedUserJSON":   linkedUser?.formatToJSON() ?? NSNull(),
                            "notSeenDuration":  notSeenDuration ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull(),
                            "userId":           userId ?? NSNull()]
        return result
    }
    
}
