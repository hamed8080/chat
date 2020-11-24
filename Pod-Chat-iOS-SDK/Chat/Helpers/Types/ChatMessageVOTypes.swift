//
//  ChatMessageVOTypes.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum ChatMessageVOTypes {
    case CREATE_THREAD                      // 1
    case MESSAGE                            // 2
    case SENT                               // 3
    case DELIVERY                           // 4
    case SEEN                               // 5
    case PING                               // 6
    case BLOCK                              // 7
    case UNBLOCK                            // 8
    case LEAVE_THREAD                       // 9
    case RENAME                             // 10    // not implemented yet!
    case ADD_PARTICIPANT                    // 11
    case GET_STATUS                         // 12    // not implemented yet!
    case GET_CONTACTS                       // 13
    case GET_THREADS                        // 14
    case GET_HISTORY                        // 15
    case CHANGE_TYPE                        // 16    // not implemented yet!
    case REMOVED_FROM_THREAD                // 17
    case REMOVE_PARTICIPANT                 // 18
    case MUTE_THREAD                        // 19
    case UNMUTE_THREAD                      // 20
    case UPDATE_THREAD_INFO                 // 21
    case FORWARD_MESSAGE                    // 22
    case USER_INFO                          // 23
    case USER_STATUS                        // 24    // not implemented yet!
    case GET_BLOCKED                        // 25
    case RELATION_INFO                      // 26    // not implemented yet!
    case THREAD_PARTICIPANTS                // 27
    case EDIT_MESSAGE                       // 28
    case DELETE_MESSAGE                     // 29
    case THREAD_INFO_UPDATED                // 30
    case LAST_SEEN_UPDATED                  // 31
    case GET_MESSAGE_DELEVERY_PARTICIPANTS  // 32
    case GET_MESSAGE_SEEN_PARTICIPANTS      // 33
    case IS_NAME_AVAILABLE                  // 34
    case JOIN_THREAD                        // 39
    case BOT_MESSAGE                        // 40    // not implemented yet!
    case SPAM_PV_THREAD                     // 41
    case SET_RULE_TO_USER                   // 42
    case REMOVE_ROLE_FROM_USER              // 43
    case CLEAR_HISTORY                      // 44
    case SYSTEM_MESSAGE                     // 46
    case GET_NOT_SEEN_DURATION              // 47
    case PIN_THREAD                         // 48
    case UNPIN_THREAD                       // 49
    case PIN_MESSAGE                        // 50
    case UNPIN_MESSAGE                      // 51
    case SET_PROFILE                        // 52
    case GET_CURRENT_USER_ROLES             // 54
    case GET_REPORT_REASONS                 // 56
    case REPORT_THREAD                      // 57
    case REPORT_USER                        // 58
    case REPORT_MESSAGE                     // 59
    case CONTACTS_LAST_SEEN                 // 60
    case ALL_UNREAD_MESSAGE_COUNT           // 61
    case CREATE_BOT                         // 62
    case DEFINE_BOT_COMMAND                 // 63
    case START_BOT                          // 64
    case STOP_BOT                           // 65
    
    case CALL_REQUEST                       // 70
    case ACCEPT_CALL                        // 71
    case REJECT_CALL                        // 72
    case DELIVER_CALL_REQUEST               // 73
    case START_CALL                         // 74
    case END_CALL_REQUEST                   // 75
    case END_CALL                           // 76
    case GET_CALLS                          // 77
    case CALL_RECONNECT                     // 78
    case CALL_CONNECT                       // 79
//    case CALL_REQUEST                       // 70
//    case CALL_ACCEPT                        // 71
//    case CALL_REJECT                        // 72
//    case CALL_REJECT                        // 73
//    case CALL_START                         // 74
    
    case CONTACT_SYNCED                     // 90
    case LOGOUT                             // 100
    case STATUS_PING                        // 101
    case CLOSE_THREAD                       // 102
    case ERROR                              // 999
    
    func intValue() -> Int {
        switch self {
        case .CREATE_THREAD:                    return 1
        case .MESSAGE:                          return 2
        case .SENT:                             return 3
        case .DELIVERY:                         return 4
        case .SEEN:                             return 5
        case .PING:                             return 6
        case .BLOCK:                            return 7
        case .UNBLOCK:                          return 8
        case .LEAVE_THREAD:                     return 9
        case .RENAME:                           return 10    // not implemented yet!
        case .ADD_PARTICIPANT:                  return 11
        case .GET_STATUS:                       return 12    // not implemented yet!
        case .GET_CONTACTS:                     return 13
        case .GET_THREADS:                      return 14
        case .GET_HISTORY:                      return 15
        case .CHANGE_TYPE:                      return 16    // not implemented yet!
        case .REMOVED_FROM_THREAD:              return 17
        case .REMOVE_PARTICIPANT:               return 18
        case .MUTE_THREAD:                      return 19
        case .UNMUTE_THREAD:                    return 20
        case .UPDATE_THREAD_INFO:               return 21
        case .FORWARD_MESSAGE:                  return 22
        case .USER_INFO:                        return 23
        case .USER_STATUS:                      return 24    // not implemented yet!
        case .GET_BLOCKED:                      return 25
        case .RELATION_INFO:                    return 26    // not implemented yet!
        case .THREAD_PARTICIPANTS:              return 27
        case .EDIT_MESSAGE:                     return 28
        case .DELETE_MESSAGE:                   return 29
        case .THREAD_INFO_UPDATED:              return 30
        case .LAST_SEEN_UPDATED:                return 31
        case .GET_MESSAGE_DELEVERY_PARTICIPANTS: return 32
        case .GET_MESSAGE_SEEN_PARTICIPANTS:    return 33
        case .IS_NAME_AVAILABLE:                return 34
        case .JOIN_THREAD:                      return 39
        case .BOT_MESSAGE:                      return 40    // not implemented yet!
        case .SPAM_PV_THREAD:                   return 41
        case .SET_RULE_TO_USER:                 return 42
        case .REMOVE_ROLE_FROM_USER:            return 43
        case .CLEAR_HISTORY:                    return 44
        case .SYSTEM_MESSAGE:                   return 46
        case .GET_NOT_SEEN_DURATION:            return 47
        case .PIN_THREAD:                       return 48
        case .UNPIN_THREAD:                     return 49
        case .PIN_MESSAGE:                      return 50
        case .UNPIN_MESSAGE:                    return 51
        case .SET_PROFILE:                      return 52
        case .GET_CURRENT_USER_ROLES:           return 54
        case .GET_REPORT_REASONS:               return 56
        case .REPORT_THREAD:                    return 57
        case .REPORT_USER:                      return 58
        case .REPORT_MESSAGE:                   return 59
        case .CONTACTS_LAST_SEEN:               return 60
        case .ALL_UNREAD_MESSAGE_COUNT:         return 61
        case .CREATE_BOT:                       return 62
        case .DEFINE_BOT_COMMAND:               return 63
        case .START_BOT:                        return 64
        case .STOP_BOT:                         return 65
        case .CALL_REQUEST:                     return 70
        case .ACCEPT_CALL:                      return 71
        case .REJECT_CALL:                      return 72
        case .DELIVER_CALL_REQUEST:             return 73
        case .START_CALL:                       return 74
        case .END_CALL_REQUEST:                 return 75
        case .END_CALL:                         return 76
        case .GET_CALLS:                        return 77
        case .CALL_RECONNECT:                   return 78
        case .CALL_CONNECT:                     return 79
//        case .CALL_REQUEST:                     return 70
//        case .CALL_ACCEPT:                      return 71
//        case .CALL_REJECT:                      return 72
//        case .CALL_START:                       return 73
        case .CONTACT_SYNCED:                   return 90
        case .LOGOUT:                           return 100
        case .STATUS_PING:                      return 101
        case .CLOSE_THREAD:                     return 102
        case .ERROR:                            return 999
        }
    }
}


