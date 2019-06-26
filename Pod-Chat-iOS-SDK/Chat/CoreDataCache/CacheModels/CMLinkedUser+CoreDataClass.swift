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
    
    public func convertCMLinkedUserToLinkedUserObject() -> LinkedUser {
        
        var id: Int?
        
        func createVariables() {
            if let id2 = self.id as? Int {
                id = id2
            }
        }
        
        func createLinkedUserModel() -> LinkedUser {
            
            let messageModel = LinkedUser(coreUserId:   id,
                                          image: self.image,
                                          name: self.name,
                                          nickname: self.nickname,
                                          username: self.username)
            return messageModel
            
        }
        
        createVariables()
        let model = createLinkedUserModel()
        return model
    }
    
}
