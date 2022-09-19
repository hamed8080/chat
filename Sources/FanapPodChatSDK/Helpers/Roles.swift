//
//  Roles.h
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation


public enum Roles: String, Codable, SafeDecodable {
    
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


    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case UNKNOWN
}


public enum RoleOperations:String {
    
    case Add         =  "add"
    case Remove      =  "remove"
}

