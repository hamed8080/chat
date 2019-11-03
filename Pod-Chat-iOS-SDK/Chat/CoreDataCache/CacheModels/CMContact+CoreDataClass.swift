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
    
    public func convertCMContactToContactObject() -> Contact {
        
        var blocked:            Bool?
        var hasUser:            Bool?
        var id:                 Int?
        var notSeenDuration:    Int?
        var userId:             Int?
        var time:               UInt?
        
        var linkedUser:         LinkedUser?
        
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
                                       linkedUser:      self.linkedUser?.convertCMLinkedUserToLinkedUserObject(),
                                       notSeenDuration: notSeenDuration,
                                       timeStamp:       time,
//                                       uniqueId:        self.uniqueId,
                                       userId:          userId)
            return messageModel
        }
        
        createVariables()
        let model = createContactModel()
        
        return model
        
    }
    
}
