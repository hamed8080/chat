//
//  UserRolesModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 4/2/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UserRolesModel {
    /*
     ---------------------------------------
     * SetRolesModel:
     *  - hasError     Bool
     *  - errorMessage String
     *  - errorCode    Int
     *  + result       JSON or UserRole:
     *      + userRoles:    [UserRoleAsJSON]
     *          - id:           Int?
     *          - name:         String?
     *          - roles:        [String]?
     ---------------------------------------
     * responseAsModel:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  + userRoles     UserRole
     ---------------------------------------
     */
    
    // userRole model properties
    public let hasError:        Bool
    public let errorMessage:    String
    public let errorCode:       Int
    
    public var threadId:        Int
    public var userRoles:       [UserRole]  = []
    public var userRolesJSON:   [JSON]      = []
    
    public init(threadId:       Int,
                messageContent: [JSON],
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.threadId = threadId
        
        for item in messageContent {
            let theUserRoleModel = UserRole(/*threadId: threadId, */messageContent: item)
            let roleJSON = theUserRoleModel.formatToJSON()
            
            userRoles.append(theUserRoleModel)
            userRolesJSON.append(roleJSON)
        }
        
    }
    
    public init(threadId:           Int,
                userRolesObject:    [UserRole],
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.threadId = threadId
        
        for item in userRolesObject {
            let theUserRoleModel = item
            let roleJSON = theUserRoleModel.formatToJSON()
            
            userRoles.append(theUserRoleModel)
            userRolesJSON.append(roleJSON)
        }
        
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["threadId":     threadId,
                            "userRoles":    userRolesJSON]
        
        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]
        
        return resultAsJSON
    }
    
}
