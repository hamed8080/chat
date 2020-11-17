//
//  CMUserRole+CoreDataClass.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//
//

import Foundation
import CoreData


public class CMUserRole: NSManagedObject {
    
    public func convertCMObjectToObject() -> UserRole {
        
        var roles:      [String]?
        var id:         Int?
//        var threadId:   Int?
        
        func createVariables() {
            
            if let id2 = self.id as? Int {
                id = id2
            }
//            if let threadId2 = self.threadId as? Int {
//                threadId = threadId2
//            }
            
            if let roles2 = roles as [String]? {
                roles = roles2
            }
            
        }
        
        func createUserRoleModel() -> UserRole {
            let userRole = UserRole(userId: id ?? 0,
                                    name: self.name ?? "",
                                    roles: roles/*,
                                    threadId: threadId ?? 0*/)
            return userRole
        }
        
        createVariables()
        let model = createUserRoleModel()
        
        return model
    }

    
}
