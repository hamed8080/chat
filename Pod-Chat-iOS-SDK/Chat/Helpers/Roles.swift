//
//  Roles.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum Roles: String {
    case CHANGE_THREAD_INFO         = "change_thread_info"
    case POST_CHANNEL_MESSAGE       = "post_channel_message"
    case EDIT_MESSAGE_OF_OTHERS     = "edit_message_of_others"
    case DELETE_MESSAGE_OF_OTHERS   = "delete_message_of_others"
    case ADD_NEW_USER               = "add_new_user"
    case REMOVE_USER                = "remove_user"
    case ADD_RULE_TO_USER           = "add_rule_to_user"
    case REMOVE_ROLE_FROM_USER      = "remove_role_from_user"
    case READ_THREAD                = "read_thread"
    case EDIT_THREAD                = "edit_thread"
    case THREAD_ADMIN               = "thread_admin"
    
    
    func returnString() -> String {
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
    
    func returnString() -> String {
        switch self {
        case .Add:      return "add"
        case .Remove:   return "remove"
        }
    }
    
}

