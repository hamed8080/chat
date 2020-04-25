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
    
    public func convertCMObjectToObject() -> Participant {
        
        var admin:              Bool?
        var auditor:            Bool?
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
            if let auditor2 = self.auditor as? Bool {
                auditor = auditor2
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
                                               auditor:         auditor,
                                               blocked:         blocked,
                                               cellphoneNumber: self.cellphoneNumber,
                                               contactFirstName: self.contactFirstName,
                                               contactId:       contactId,
                                               contactName:     self.contactName,
                                               contactLastName: self.contactLastName,
                                               coreUserId:      coreUserId,
                                               email:           self.email,
                                               firstName:       self.firstName,
                                               id:              id,
                                               image:           self.image,
                                               keyId:           self.keyId,
                                               lastName:        self.lastName,
                                               myFriend:        myFriend,
                                               name:            self.name,
                                               notSeenDuration: notSeenDuration,
                                               online:          online,
                                               receiveEnable:   receiveEnable,
                                               roles:           roles,
                                               sendEnable:      sendEnable,
                                               username:        self.username,
                                               chatProfileVO:   Profile(bio: bio, metadata: metadata))
            
            return participantModel
        }
        
        
        createVariables()
        let model = createMessageModel()
        
        return model
    }
    
    
    func updateObject(with participant: Participant, isAdminRequest: Bool) {
        
        if let auditor = participant.auditor as NSNumber? {
            self.auditor = auditor
        }
        if let blocked = participant.blocked as NSNumber? {
            self.blocked = blocked
        }
        if let cellphoneNumber = participant.cellphoneNumber {
            self.cellphoneNumber = cellphoneNumber
        }
        if let contactFirstName = participant.contactFirstName {
            self.contactFirstName = contactFirstName
        }
        if let contactId = participant.contactId as NSNumber? {
            self.contactId = contactId
        }
        if let contactName = participant.contactName {
            self.contactName = contactName
        }
        if let contactLastName = participant.contactLastName {
            self.contactLastName = contactLastName
        }
        if let email = participant.email {
            self.email = email
        }
        if let firstName = participant.firstName {
            self.firstName = firstName
        }
        if let id = participant.id as NSNumber? {
            self.id = id
        }
        if let image = participant.image {
            self.image = image
        }
        if let keyId = participant.keyId {
            self.keyId = keyId
        }
        if let lastName = participant.lastName {
            self.lastName = lastName
        }
        if let myFriend = participant.myFriend as NSNumber? {
            self.myFriend = myFriend
        }
        if let name = participant.name {
            self.name = name
        }
        if let notSeenDuration = participant.notSeenDuration as NSNumber? {
            self.notSeenDuration = notSeenDuration
        }
        if let online = participant.online as NSNumber? {
            self.online = online
        }
        if let receiveEnable = participant.receiveEnable as NSNumber? {
            self.receiveEnable = receiveEnable
        }
        if isAdminRequest {
            self.roles = (participant.roles != []) ? participant.roles : nil
        } else {
            self.roles = ((participant.roles?.count ?? 0) > 0) ? participant.roles : self.roles
        }
        if let sendEnable = participant.sendEnable as NSNumber? {
            self.sendEnable = sendEnable
        }
        if let theThreadId = threadId as NSNumber? {
            self.threadId = theThreadId
        }
        if let username = participant.username {
            self.username = username
        }
        
        self.admin      = ((self.roles?.count ?? 0) > 0) ? true : false
        self.time       = Int(Date().timeIntervalSince1970) as NSNumber?
        self.bio        = participant.chatProfileVO?.bio
        self.metadata   = participant.chatProfileVO?.metadata
        
    }
    
    
}
