//
//  GetCurrentUserRolesResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/8/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class GetCurrentUserRolesModel: ResponseModel, ResponseModelDelegates {
    
    public var userRoles:       [Roles] = []
    
    public init(messageContent: [String],
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        var roles = [Roles]()
        for item in messageContent {
            switch item {
            case Roles.ADD_NEW_USER.stringValue():              roles.append(Roles.ADD_NEW_USER)
            case Roles.ADD_RULE_TO_USER.stringValue():          roles.append(Roles.ADD_RULE_TO_USER)
            case Roles.CHANGE_THREAD_INFO.stringValue():        roles.append(Roles.CHANGE_THREAD_INFO)
            case Roles.DELETE_MESSAGE_OF_OTHERS.stringValue():  roles.append(Roles.DELETE_MESSAGE_OF_OTHERS)
            case Roles.EDIT_MESSAGE_OF_OTHERS.stringValue():    roles.append(Roles.EDIT_MESSAGE_OF_OTHERS)
            case Roles.EDIT_THREAD.stringValue():               roles.append(Roles.EDIT_THREAD)
            case Roles.POST_CHANNEL_MESSAGE.stringValue():      roles.append(Roles.POST_CHANNEL_MESSAGE)
            case Roles.REMOVE_ROLE_FROM_USER.stringValue():     roles.append(Roles.REMOVE_ROLE_FROM_USER)
            case Roles.REMOVE_USER.stringValue():               roles.append(Roles.REMOVE_USER)
            case Roles.READ_THREAD.stringValue():               roles.append(Roles.READ_THREAD)
            case Roles.REMOVE_USER.stringValue():               roles.append(Roles.REMOVE_USER)
            default: break
            }
        }
        userRoles = roles
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(userRoles:      [Roles],
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.userRoles          = userRoles
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        var roles = [String]()
        for item in userRoles {
            roles.append(item.stringValue())
        }
        let result: JSON = ["userRoles":    roles]
        let finalResult: JSON = ["result":      result,
                                 "hasError":    hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode":   errorCode]
        
        return finalResult
    }
    
}

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class GetCurrentUserRolesResponse: GetCurrentUserRolesModel {
    
}
