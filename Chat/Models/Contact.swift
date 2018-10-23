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
     * + ContactVO                        {object}
     *    - id                            {long}
     *    - userId                        {long}
     *    - firstName                     {string}
     *    - lastName                      {string}
     *    - image                         {string}
     *    - email                         {string}
     *    - cellphoneNumber               {string}
     *    - uniqueId                      {string}
     *    - notSeenDuration               {long}
     *    - hasUser                       {boolean}
     *    - linkedUser                    {object : RelatedUserVO}
     */
    
    let id:                 Int?
    let userId:             Int?
    let firstName:          String?
    let lastName:           String?
    let image:              String?
    let email:              String?
    let cellphoneNumber:    String?
    let uniqueId:           String?
    let notSeenDuration:    Int?
    let hasUser:            Bool?
    var linkedUser:         LinkedUser?
    
    init(messageContent: JSON) {
        self.id                 = messageContent["id"].int
        self.userId             = messageContent["userId"].int
        self.firstName          = messageContent["firstName"].string
        self.lastName           = messageContent["lastName"].string
        self.image              = messageContent["profileImage"].string
        self.email              = messageContent["email"].string
        self.cellphoneNumber    = messageContent["cellphoneNumber"].string
        self.uniqueId           = messageContent["uniqueId"].string
        self.notSeenDuration    = messageContent["notSeenDuration"].int
        self.hasUser            = messageContent["hasUser"].bool
        
        if let tempLinkUser = messageContent["linkedUser"].array {
            self.linkedUser = LinkedUser(messageContent: tempLinkUser.first!)
        }
        
    }
    
    func formatDataToMakeContact() -> Contact {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["id":               id ?? NSNull(),
                            "userId":           userId ?? NSNull(),
                            "firstName":        firstName ?? NSNull(),
                            "lastName":         lastName ?? NSNull(),
                            "image":            image ?? NSNull(),
                            "email":            email ?? NSNull(),
                            "cellphoneNumber":  cellphoneNumber ?? NSNull(),
                            "uniqueId":         uniqueId ?? NSNull(),
                            "notSeenDuration":  notSeenDuration ?? NSNull(),
                            "hasUser":          hasUser ?? NSNull(),
                            "linkedUserJSON":   linkedUser?.formatToJSON() ?? NSNull()]
        return result
    }
    
}
