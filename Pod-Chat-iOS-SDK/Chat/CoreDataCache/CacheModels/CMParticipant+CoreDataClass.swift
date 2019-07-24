//
//  CMParticipant+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMParticipant: NSManagedObject {
    
    public func convertCMParticipantToParticipantObject() -> Participant {
        
        var admin:              Bool?
        var blocked:            Bool?
        var contactId:          Int?
        var coreUserId:         Int?
        var id:                 Int?
        var myFriend:           Bool?
        var notSeenDuration:    Int?
        var online:             Bool?
        var receiveEnable:      Bool?
        var roles:              [String]?
        var sendEnable:         Bool?
        
        func createVariables() {
            if let admin2 = self.admin as? Bool {
                admin = admin2
            }
            if let blocked2 = self.blocked as? Bool {
                blocked = blocked2
            }
            if let contactId2 = self.contactId as? Int {
                contactId = contactId2
            }
            if let coreUserId2 = self.coreUserId as? Int {
                coreUserId = coreUserId2
            }
            if let id2 = self.id as? Int {
                id = id2
            }
            if let myFriend2 = self.myFriend as? Bool {
                myFriend = myFriend2
            }
            if let notSeenDuration2 = self.notSeenDuration as? Int {
                notSeenDuration = notSeenDuration2
            }
            if let online2 = self.online as? Bool {
                online = online2
            }
            if let receiveEnable2 = self.receiveEnable as? Bool {
                receiveEnable = receiveEnable2
            }
            if let roles2 = self.roles {
                roles = roles2
            }
            if let sendEnable2 = self.sendEnable as? Bool {
                sendEnable = sendEnable2
            }
        }
        
        func createMessageModel() -> Participant {
            let participantModel = Participant(admin:           admin,
                                               blocked:         blocked,
                                               cellphoneNumber: self.cellphoneNumber,
                                               contactId:       contactId,
                                               coreUserId:      coreUserId,
                                               email:           self.email,
                                               firstName:       self.firstName,
                                               id:              id,
                                               image:           self.image,
                                               lastName:        self.lastName,
                                               myFriend:        myFriend,
                                               name:            self.name,
                                               notSeenDuration: notSeenDuration,
                                               online:          online,
                                               receiveEnable:   receiveEnable,
                                               roles:           roles,
                                               sendEnable:      sendEnable)
            
            return participantModel
        }
        
        
        createVariables()
        let model = createMessageModel()
        
        return model
    }
}
