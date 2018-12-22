//
//  CMParticipant+CoreDataClass.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMParticipant: NSManagedObject {
    
    public func convertCMParticipantToParticipantObject() -> Participant {
        
        var contactId:          Int?
        var id:                 Int?
        var myFriend:           Bool?
        var notSeenDuration:    Int?
        var online:             Bool?
        var receiveEnable:      Bool?
        var sendEnable:         Bool?
        
        func createVariables() {
            if let contactId2 = self.contactId as? Int {
                contactId = contactId2
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
            if let sendEnable2 = self.sendEnable as? Bool {
                sendEnable = sendEnable2
            }
        }
        
        func createMessageModel() -> Participant {
            let participantModel = Participant(cellphoneNumber: self.cellphoneNumber,
                                               contactId:       contactId,
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
                                               sendEnable:      sendEnable)
            
            return participantModel
        }
        
        
        createVariables()
        let model = createMessageModel()
        
        return model
    }
    
}
