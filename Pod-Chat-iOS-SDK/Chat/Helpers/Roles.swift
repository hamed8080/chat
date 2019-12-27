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
}


public enum RoleOperations: String {
    case Add    = "add"
    case Remove = "remove"
}

