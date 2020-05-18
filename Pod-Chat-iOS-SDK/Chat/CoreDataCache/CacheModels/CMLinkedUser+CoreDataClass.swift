//
//  CMLinkedUser+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMLinkedUser: NSManagedObject {
    
    public func convertCMObjectToObject() -> LinkedUser {
        
        var coreUserId: Int?
        
        func createVariables() {
            if let coreUserId2 = self.coreUserId as? Int {
                coreUserId = coreUserId2
            }
        }
        
        func createLinkedUserModel() -> LinkedUser {
            
            let messageModel = LinkedUser(coreUserId:   coreUserId,
                                          image:        self.image,
                                          name:         self.name,
                                          nickname:     self.nickname,
                                          username:     self.username)
            return messageModel
            
        }
        
        createVariables()
        let model = createLinkedUserModel()
        return model
    }
    
    
    func updateObject(with linkedUser: LinkedUser) {
        if let coreUserId = linkedUser.coreUserId as NSNumber? {
            self.coreUserId = coreUserId
        }
        if let image = linkedUser.image {
            self.image = image
        }
        if let name = linkedUser.name {
            self.name = name
        }
        if let nickname = linkedUser.nickname {
            self.nickname = nickname
        }
        if let username = linkedUser.username {
            self.username = username
        }
    }
    
}
