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
     * + ParticipantVO      Participant:
     *    - cellphoneNumber:    String?
     *    - contactId:          Int?
     *    - email:              String?
     *    - firstName:          String?
     *    - id:                 Int?
     *    - image:              String?
     *    - lastName:           String?
     *    - myFriend:           Bool?
     *    - name:               String?
     *    - notSeenDuration:    Int?
     *    - online:             Bool?
     *    - receiveEnable:      Bool?
     *    - sendEnable:         Bool?
     */
    
    let cellphoneNumber:    String?
    let contactId:          Int?
    let email:              String?
    let firstName:          String?
    let id:                 Int?
    let image:              String?
    let lastName:           String?
    let myFriend:           Bool?
    let name:               String?
    let notSeenDuration:    Int?
    let online:             Bool?
    let receiveEnable:      Bool?
    let sendEnable:         Bool?
    
    init(messageContent: JSON) {
        self.cellphoneNumber    = messageContent["cellphoneNumber"].string
        self.contactId          = messageContent["contactId"].int
        self.email              = messageContent["email"].string
        self.firstName          = messageContent["firstName"].string
        self.id                 = messageContent["id"].int
        self.image              = messageContent["image"].string
        self.lastName           = messageContent["lastName"].string
        self.myFriend           = messageContent["myFriend"].bool
        self.name               = messageContent["name"].string
        self.notSeenDuration    = messageContent["notSeenDuration"].int
        self.online             = messageContent["online"].bool
        self.receiveEnable      = messageContent["receiveEnable"].bool
        self.sendEnable         = messageContent["sendEnable"].bool
    }
    
    func formatDataToMakeParticipant() -> Participant {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["cellphoneNumber":  cellphoneNumber ?? NSNull(),
                            "contactId":        contactId ?? NSNull(),
                            "email":            email ?? NSNull(),
                            "firstName":        firstName ?? NSNull(),
                            "id":               id ?? NSNull(),
                            "image":            image ?? NSNull(),
                            "lastName":         lastName ?? NSNull(),
                            "myFriend":         myFriend ?? NSNull(),
                            "name":             name ?? NSNull(),"notSeenDuration":  notSeenDuration ?? NSNull(),
                            "online":           online ?? NSNull(),"receiveEnable":    receiveEnable ?? NSNull(),
                            "sendEnable":       sendEnable ?? NSNull()]
        return result
    }
    
}
