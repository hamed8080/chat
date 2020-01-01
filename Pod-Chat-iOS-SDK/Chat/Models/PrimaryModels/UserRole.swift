//
//  UserRole.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class UserRole {
    /*
     * + UserRole   UserRole:
     *    - id:         Int?
     *    - name:       String?
     *    - roles:      [String]?
     */
    
    public var userId:      Int
    public var name:        String
    public var roles:       [String]?
//    public let threadId:    Int?
    
    public init(/*threadId: Int?, */messageContent: JSON) {
        
//        self.threadId   = threadId
        self.userId     = messageContent["id"].intValue
        self.name       = messageContent["name"].stringValue
//        for item in messageContent["roles"].arrayObject
        if let myRoles = messageContent["roles"].arrayObject as? [String]? {
            self.roles = myRoles
        }
    }
    
    public init(userId:     Int,
                name:       String,
                roles:      [String]?/*,
                threadId:   Int?*/) {
        
        self.userId     = userId
        self.name       = name
        self.roles      = roles
//        self.threadId   = threadId
    }
    
    public init(theUserRole: UserRole) {
        self.userId     = theUserRole.userId
        self.name       = theUserRole.name
        self.roles      = theUserRole.roles
//        self.threadId   = theUserRole.threadId
    }
    
    
    public func formatDataToMakeRole() -> UserRole {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["id":       userId,
                            "name":     name,
                            "roles":    roles ?? NSNull()/*,
                            "threadId": threadId ?? NSNull()*/]
        return result
    }
    
}
