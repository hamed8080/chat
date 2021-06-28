//
//  Roles.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum Roles: String , Codable {
    
    case CHANGE_THREAD_INFO       = "CHANGE_THREAD_INFO"
    case POST_CHANNEL_MESSAGE     = "POST_CHANNEL_MESSAGE"
    case EDIT_MESSAGE_OF_OTHERS   = "EDIT_MESSAGE_OF_OTHERS"
    case DELETE_MESSAGE_OF_OTHERS = "DELETE_MESSAGE_OF_OTHERS"
    case ADD_NEW_USER             = "ADD_NEW_USER"
    case REMOVE_USER              = "REMOVE_USER"
    case ADD_RULE_TO_USER         = "ADD_RULE_TO_USER"
    case REMOVE_ROLE_FROM_USER    = "REMOVE_ROLE_FROM_USER"
    case READ_THREAD              = "READ_THREAD"
    case EDIT_THREAD              = "EDIT_THREAD"
    case THREAD_ADMIN             = "THREAD_ADMIN"
    case OWNERSHIP                = "OWNERSHIP"
    case unknown
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
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
        case .OWNERSHIP:                return "OWNERSHIP"
        case .unknown:                  return "unknown"
        }
    }
    
    //prevent crash when new case added from server side
    public init(from decoder: Decoder) throws {
        guard let value = try? decoder.singleValueContainer().decode(String.self) else{
            self = .unknown
            return
        }
        self = Roles(rawValue: value) ?? .unknown
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

