//
//  ThreadEventTypes.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 1/30/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum ThreadEventTypes {
    
    case THREAD_CLOSED
    case THREAD_UNREAD_COUNT_UPDATED    // type 31
    case THREAD_LAST_ACTIVITY_TIME      //
    case THREAD_PIN
    case THREAD_UNPIN
    case THREAD_INFO_UPDATED            // type 21
    case THREAD_ADD_ADMIN
    case THREAD_REMOVE_ADMIN
    case THREAD_ADD_PARTICIPANTS        // type 11
    case THREAD_LEAVE_SAFTLY_FAILED
    case THREAD_LEAVE_PARTICIPANT       // type 9
    case THREAD_REMOVED_FROM            // type 17
    case THREAD_MUTE                    // type 19
    case THREAD_UNMUTE                  // type 20
    case THREADS_LIST_CHANGE            //
    case THREAD_PARTICIPANTS_LIST_CHANGE//
    case THREAD_DELETE
    case THREAD_NEW                     // type 1
    case THREAD_REMOVE_PARTICIPANTS     // type 18
    case MESSAGE_PIN
    case MESSAGE_UNPIN
//    case THREAD_PARTICIPANT_NEW
//    case THREAD_PARTICIPANT_DELETE
 
}


