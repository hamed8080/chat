//
//  NewChatMessageVOTypes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/22/21.
//

import Foundation
public enum NewChatMessageVOTypes :Int , Codable {
    case CREATE_THREAD                     = 1
    case MESSAGE                           = 2
    case SENT                              = 3
    case DELIVERY                          = 4
    case SEEN                              = 5
    case PING                              = 6
    case BLOCK                             = 7
    case UNBLOCK                           = 8
    case LEAVE_THREAD                      = 9
    case RENAME                            = 10// not implemented yet!
    case ADD_PARTICIPANT                   = 11
    case GET_STATUS                        = 12// not implemented yet!
    case GET_CONTACTS                      = 13
    case GET_THREADS                       = 14
    case GET_HISTORY                       = 15
    case CHANGE_TYPE                       = 16// not implemented yet!
    case REMOVED_FROM_THREAD               = 17
    case REMOVE_PARTICIPANT                = 18
    case MUTE_THREAD                       = 19
    case UNMUTE_THREAD                     = 20
    case UPDATE_THREAD_INFO                = 21
    case FORWARD_MESSAGE                   = 22
    case USER_INFO                         = 23
    case USER_STATUS                       = 24// not implemented yet!
    case GET_BLOCKED                       = 25
    case RELATION_INFO                     = 26// not implemented yet!
    case THREAD_PARTICIPANTS               = 27
    case EDIT_MESSAGE                      = 28
    case DELETE_MESSAGE                    = 29
    case THREAD_INFO_UPDATED               = 30
    case LAST_SEEN_UPDATED                 = 31
    case GET_MESSAGE_DELEVERY_PARTICIPANTS = 32
    case GET_MESSAGE_SEEN_PARTICIPANTS     = 33
    case IS_NAME_AVAILABLE                 = 34
    case JOIN_THREAD                       = 39
    case BOT_MESSAGE                       = 40
    case SPAM_PV_THREAD                    = 41
    case SET_RULE_TO_USER                  = 42
    case REMOVE_ROLE_FROM_USER             = 43
    case CLEAR_HISTORY                     = 44
    case SYSTEM_MESSAGE                    = 46
    case GET_NOT_SEEN_DURATION             = 47
    case PIN_THREAD                        = 48
    case UNPIN_THREAD                      = 49
    case PIN_MESSAGE                       = 50
    case UNPIN_MESSAGE                     = 51
    case SET_PROFILE                       = 52
    case GET_CURRENT_USER_ROLES            = 54
    case GET_REPORT_REASONS                = 56// not implemented yet!
    case REPORT_THREAD                     = 57
    case REPORT_USER                       = 58
    case REPORT_MESSAGE                    = 59
    case CONTACTS_LAST_SEEN                = 60
    case ALL_UNREAD_MESSAGE_COUNT          = 61
    case CREATE_BOT                        = 62
    case DEFINE_BOT_COMMAND                = 63
    case START_BOT                         = 64
    case STOP_BOT                          = 65
    case CONTACT_SYNCED                    = 90
    case LOGOUT                            = 100
    case STATUS_PING                       = 101
    case CLOSE_THREAD                      = 102
    case REGISTER_ASSISTANT                = 107
    case DEACTICVE_ASSISTANT               = 108
    case GET_ASSISTANTS                    = 109
    case GET_ASSISTANT_HISTORY             = 115
    case ERROR                             = 999
}
