//
//  CMUser+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMUser: NSManagedObject {
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func convertCMObjectToObject() -> User {
        
        var coreUserId:     Int?
        var contactSynced:  Bool?
        var id:             Int?
        var lastSeen:       Int?
        var receiveEnable:  Bool?
        var sendEnable:     Bool?
        
        
        func createVariables() {
            if let coreUserId2 = self.coreUserId as? Int {
                coreUserId = coreUserId2
            }
            if let contactSynced2 = self.contactSynced as? Bool {
                contactSynced = contactSynced2
            }
            if let id2 = self.id as? Int {
                id = id2
            }
            if let lastSeen2 = self.lastSeen as? Int {
                lastSeen = lastSeen2
            }
            if let receiveEnable2 = self.receiveEnable as? Bool {
                receiveEnable = receiveEnable2
            }
            if let sendEnable2 = self.sendEnable as? Bool {
                sendEnable = sendEnable2
            }
        }
        
        func createUserModel() -> User {
            let userModel = User(cellphoneNumber: self.cellphoneNumber,
                                 contactSynced: contactSynced,
                                 coreUserId:    coreUserId,
                                 email:         self.email,
                                 id:            id,
                                 image:         self.image,
                                 lastSeen:      lastSeen,
                                 name:          self.name,
                                 receiveEnable: receiveEnable,
                                 sendEnable:    sendEnable,
                                 username:      username,
                                 chatProfileVO: Profile(bio: bio, metadata: metadata))
            return userModel
        }
        
        createVariables()
        let model = createUserModel()
        
        return model
    }
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    func updateObject(with user: User) {
        self.cellphoneNumber = user.cellphoneNumber
        self.contactSynced  = user.contactSynced as NSNumber?
        self.coreUserId     = user.coreUserId as NSNumber?
        self.email          = user.email
        self.id             = user.id as NSNumber?
        self.image          = user.image
        self.lastSeen       = user.lastSeen as NSNumber?
        self.name           = user.name
        self.receiveEnable  = user.receiveEnable as NSNumber?
        self.sendEnable     = user.sendEnable as NSNumber?
        self.username       = user.username
        self.bio            = user.chatProfileVO?.bio
        self.metadata       = user.chatProfileVO?.metadata
    }
    
}
