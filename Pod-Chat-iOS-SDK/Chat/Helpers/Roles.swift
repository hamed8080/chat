//
//  Roles.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum Roles: String {
    
    case CHANGE_THREAD_INFO
    case POST_CHANNEL_MESSAGE
    case EDIT_MESSAGE_OF_OTHERS
    case DELETE_MESSAGE_OF_OTHERS
    case ADD_NEW_USER
    case REMOVE_USER
    case ADD_RULE_TO_USER
    case REMOVE_ROLE_FROM_USER
    case READ_THREAD
    case EDIT_THREAD
    case THREAD_ADMIN
    
    func stringValue() -> String {
        switch self {
        case .CHANGE_THREAD_INFO:       return "CHANGE_THREAD_INFO"
        case .POST_CHANNEL_MESSAGE:     return "POST_CHANNEL_MESSAGE"
        case .EDIT_MESSAGE_OF_OTHERS:   return "EDIT_MESSAGE_OF_OTHERS"
        case .DELETE_MESSAGE_OF_OTHERS: return "DELETE_MESSAGE_OF_OTHERS"
        case .ADD_NEW_USER:             return "ADD_NEW_USER"
        case .REMOVE_USER:              return "REMOVE_USER"
        case .ADD_RULE_TO_USER:         return "ADD_RULE_TO_USER"
        case .REMOVE_ROLE_FROM_USER:    return "REMOVE_ROLE_FROM_USER"
        case .READ_THREAD:              return "READ_THREAD"
        case .EDIT_THREAD:              return "EDIT_THREAD"
        case .THREAD_ADMIN:             return "THREAD_ADMIN"
        }
    }
    
}


public enum RoleOperations {
    
    case Add
    case Remove
    
    func returnStringValue() -> String {
        switch self {
        case .Add:      return "add"
        case .Remove:   return "remove"
        }
    }
    
}

