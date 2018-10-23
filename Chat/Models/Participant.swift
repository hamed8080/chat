//
//  Participant.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      Participant        (formatDataToMakeParticipant)
//#######################################################################################

class Participant {
    /*
     * + ParticipantVO                   {object}
     *    - id                           {long}
     *    - sendEnable                   {boolean}
     *    - receiveEnable                {boolean}
     *    - firstName                    {string}
     *    - lastName                     {string}
     *    - name                         {string}
     *    - cellphoneNumber              {string}
     *    - email                        {string}
     *    - myFriend                     {boolean}
     *    - online                       {boolean}
     *    - notSeenDuration              {long}
     *    - userId                       {long}
     *    - image                        {string}
     */
    
    let id:                 Int?
    let sendEnable:         Bool?
    let receiveEnable:      Bool?
    let firstName:          String?
    let lastName:           String?
    let name:               String?
    let cellphoneNumber:    String?
    let email:              String?
    let myFriend:           Bool?
    let online:             Bool?
    let notSeenDuration:    Int?
    let contactId:          Int?
    let image:              String?
    
    init(messageContent: JSON) {
        self.id                 = messageContent["id"].int
        self.sendEnable         = messageContent["sendEnable"].bool
        self.receiveEnable      = messageContent["receiveEnable"].bool
        self.firstName          = messageContent["firstName"].string
        self.lastName           = messageContent["lastName"].string
        self.name               = messageContent["name"].string
        self.cellphoneNumber    = messageContent["cellphoneNumber"].string
        self.email              = messageContent["email"].string
        self.myFriend           = messageContent["myFriend"].bool
        self.online             = messageContent["online"].bool
        self.notSeenDuration    = messageContent["notSeenDuration"].int
        self.contactId          = messageContent["contactId"].int
        self.image              = messageContent["image"].string
    }
    
    func formatDataToMakeParticipant() -> Participant {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["id":               id ?? NSNull(),
                            "sendEnable":       sendEnable ?? NSNull(),
                            "receiveEnable":    receiveEnable ?? NSNull(),
                            "firstName":        firstName ?? NSNull(),
                            "lastName":         lastName ?? NSNull(),
                            "name":             name ?? NSNull(),
                            "cellphoneNumber":  cellphoneNumber ?? NSNull(),
                            "email":            email ?? NSNull(),
                            "myFriend":         myFriend ?? NSNull(),
                            "online":           online ?? NSNull(),
                            "notSeenDuration":  notSeenDuration ?? NSNull(),
                            "contactId":        contactId ?? NSNull(),
                            "image":            image ?? NSNull()]
        return result
    }
    
}
