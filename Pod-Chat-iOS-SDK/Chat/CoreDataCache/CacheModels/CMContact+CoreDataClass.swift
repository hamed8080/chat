//
//  CMContact+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMContact: NSManagedObject {
    
    public func convertCMObjectToObject() -> Contact {
        
        var blocked:            Bool?
        var hasUser:            Bool?
        var id:                 Int?
        var notSeenDuration:    Int?
        var userId:             Int?
        var time:               UInt?
        
//        var linkedUser:         LinkedUser?
        
        func createVariables() {
            
            if let blocked2 = self.blocked as? Bool {
                blocked = blocked2
            }
            if let hasUser2 = self.hasUser as? Bool {
                hasUser = hasUser2
            }
            if let id2 = self.id as? Int {
                id = id2
            }
            if let notSeenDuration2 = self.notSeenDuration as? Int {
                notSeenDuration = notSeenDuration2
            }
            if let userId2 = self.userId as? Int {
                userId = userId2
            }
            if let time2 = self.time as? UInt {
                time = time2
            }
        }
        
        func createContactModel() -> Contact {
            let messageModel = Contact(blocked:         blocked,
                                       cellphoneNumber: self.cellphoneNumber,
                                       email:           self.email,
                                       firstName:       self.firstName,
                                       hasUser:         hasUser ?? false,
                                       id:              id,
                                       image:           self.image,
                                       lastName:        self.lastName,
                                       linkedUser:      self.linkedUser?.convertCMObjectToObject(),
                                       notSeenDuration: notSeenDuration,
                                       timeStamp:       time,
                                       userId:          userId)
            return messageModel
        }
        
        createVariables()
        let model = createContactModel()
        
        return model
        
    }
    
    
    
    
    func updateObject(with contact: Contact) {
        if let blocked = contact.blocked as NSNumber? {
            self.blocked = blocked
        }
        if let cellphoneNumber = contact.cellphoneNumber {
            self.cellphoneNumber = cellphoneNumber
        }
        if let email = contact.email {
            self.email = email
        }
        if let firstName = contact.firstName {
            self.firstName = firstName
        }
        if let hasUser = contact.hasUser as NSNumber? {
            self.hasUser = hasUser
        }
        if let id = contact.id as NSNumber? {
            self.id = id
        }
        if let image = contact.image {
            self.image = image
        }
        if let lastName = contact.lastName {
            self.lastName = lastName
        }
        if let notSeenDuration = contact.notSeenDuration as NSNumber? {
            self.notSeenDuration = notSeenDuration
        }
        if let userId = contact.userId as NSNumber? {
            self.userId = userId
        }
        
        self.time = Int(Date().timeIntervalSince1970) as NSNumber?
    }
    
    
}
