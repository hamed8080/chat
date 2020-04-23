//
//  UserRolesResponse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 4/2/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UserRolesResponse: ResponseModel, ResponseModelDelegates {
    
    public var threadId:    Int
    public var userRoles:   [UserRole]  = []
    
    public init(threadId:       Int,
                messageContent: [JSON],
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.threadId = threadId
        
        for item in messageContent {
            let theUserRoleModel = UserRole(/*threadId: threadId, */messageContent: item)
            userRoles.append(theUserRoleModel)
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(threadId:           Int,
                userRolesObject:    [UserRole],
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        self.threadId = threadId
        
        for item in userRolesObject {
            userRoles.append(item)
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        var userRolesArr = [JSON]()
        for item in userRoles {
            userRolesArr.append(item.formatToJSON())
        }
        let result: JSON = ["threadId":     threadId,
                            "userRoles":    userRolesArr]
        
        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]
        
        return resultAsJSON
    }
    
}


open class UserRolesModel: UserRolesResponse {
    
}

