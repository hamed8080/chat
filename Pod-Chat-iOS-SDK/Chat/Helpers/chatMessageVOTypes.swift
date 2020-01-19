//
//  chatMessageVOTypes.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum chatMessageVOTypes: Int {
    case CREATE_THREAD                      = 1
    case MESSAGE                            = 2
    case SENT                               = 3
    case DELIVERY                           = 4
    case SEEN                               = 5
    case PING                               = 6
    case BLOCK                              = 7
    case UNBLOCK                            = 8
    case LEAVE_THREAD                       = 9
    case RENAME                             = 10    // not implemented yet!
    case ADD_PARTICIPANT                    = 11
    case GET_STATUS                         = 12    // not implemented yet!
    case GET_CONTACTS                       = 13
    case GET_THREADS                        = 14
    case GET_HISTORY                        = 15
    case CHANGE_TYPE                        = 16    // not implemented yet!
    case REMOVED_FROM_THREAD                = 17
    case REMOVE_PARTICIPANT                 = 18
    case MUTE_THREAD                        = 19
    case UNMUTE_THREAD                      = 20
    case UPDATE_THREAD_INFO                 = 21
    case FORWARD_MESSAGE                    = 22
    case USER_INFO                          = 23
    case USER_STATUS                        = 24    // not implemented yet!
    case GET_BLOCKED                        = 25
    case RELATION_INFO                      = 26    // not implemented yet!
    case THREAD_PARTICIPANTS                = 27
    case EDIT_MESSAGE                       = 28
    case DELETE_MESSAGE                     = 29
    case THREAD_INFO_UPDATED                = 30
    case LAST_SEEN_UPDATED                  = 31
    case GET_MESSAGE_DELEVERY_PARTICIPANTS  = 32
    case GET_MESSAGE_SEEN_PARTICIPANTS      = 33
    case BOT_MESSAGE                        = 40    // not implemented yet!
    case SPAM_PV_THREAD                     = 41
    case SET_RULE_TO_USER                   = 42
    case REMOVE_ROLE_FROM_USER              = 43
    case CLEAR_HISTORY                      = 44
    case SYSTEM_MESSAGE                     = 46
    case GET_NOT_SEEN_DURATION              = 47
    case PIN_THREAD                         = 48
    case UNPIN_THREAD                       = 49
    case PIN_MESSAGE                        = 50
    case UNPIN_MESSAGE                      = 51
    case LOGOUT                             = 100
    case ERROR                              = 999
}


