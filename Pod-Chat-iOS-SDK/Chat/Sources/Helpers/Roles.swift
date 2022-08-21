//
//  Roles.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
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
    
    //prevent crash when new case added from server side
    public init(from decoder: Decoder) throws {
        guard let value = try? decoder.singleValueContainer().decode(String.self) else{
            self = .unknown
            return
        }
        self = Roles(rawValue: value) ?? .unknown
    }
}


public enum RoleOperations:String {
    
    case Add         =  "add"
    case Remove      =  "remove"
}

