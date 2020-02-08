//
//  GetCurrentUserRolesModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/8/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class GetCurrentUserRolesModel {
    
    public let hasError:        Bool
    public let errorMessage:    String
    public let errorCode:       Int
    
    public var userRoles:       [Roles] = []
    
    public init(messageContent: [String],
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        var roles = [Roles]()
//        if let stringOfRoles = messageContent.arrayObject as? [String] {
//
//        }
        for item in messageContent {
            switch item {
            case Roles.ADD_NEW_USER.returnString():             roles.append(Roles.ADD_NEW_USER)
            case Roles.ADD_RULE_TO_USER.returnString():         roles.append(Roles.ADD_RULE_TO_USER)
            case Roles.CHANGE_THREAD_INFO.returnString():       roles.append(Roles.CHANGE_THREAD_INFO)
            case Roles.DELETE_MESSAGE_OF_OTHERS.returnString(): roles.append(Roles.DELETE_MESSAGE_OF_OTHERS)
            case Roles.EDIT_MESSAGE_OF_OTHERS.returnString():   roles.append(Roles.EDIT_MESSAGE_OF_OTHERS)
            case Roles.EDIT_THREAD.returnString():              roles.append(Roles.EDIT_THREAD)
            case Roles.POST_CHANNEL_MESSAGE.returnString():     roles.append(Roles.POST_CHANNEL_MESSAGE)
            case Roles.REMOVE_ROLE_FROM_USER.returnString():    roles.append(Roles.REMOVE_ROLE_FROM_USER)
            case Roles.REMOVE_USER.returnString():              roles.append(Roles.REMOVE_USER)
            case Roles.READ_THREAD.returnString():              roles.append(Roles.READ_THREAD)
            case Roles.REMOVE_USER.returnString():              roles.append(Roles.REMOVE_USER)
            default: break
            }
        }
        userRoles = roles
        
    }
    
    public init(userRoles:      [Roles],
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        self.userRoles          = userRoles
    }
    
    
    public func returnDataAsJSON() -> JSON {
        var roles = [String]()
        for item in userRoles {
            roles.append(item.returnString())
        }
        let result: JSON = ["userRoles":    roles]
        let finalResult: JSON = ["result":      result,
                                 "hasError":    hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode":   errorCode]
        
        return finalResult
    }
    
}
