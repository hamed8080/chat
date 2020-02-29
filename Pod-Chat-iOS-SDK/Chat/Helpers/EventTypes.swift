//
//  EventTypes.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum ContactEventTypes {
    
    case CONTACTS_LIST_CHANGE           //
    case CONTACTS_SEARCH_RESULT_CHANGE  //
    case CONTACTS_LAST_SEEN
    
//    case CONTACT_NEW
//    case CONTACT_DELETE
    
    /*
    case getContacts        // type 13
    case addContact
    case updateContact
    case removeContact
    case BlockContact       // type 7
    case GetBlockedList     // type 25
    case UnblockContact     // type 8
    */
}

public enum ThreadEventTypes {
    
    case THREAD_UNREAD_COUNT_UPDATED    // type 31
    case THREAD_LAST_ACTIVITY_TIME      //
    case THREAD_PIN
    case THREAD_UNPIN
    case THREAD_INFO_UPDATED            // type 21
    case THREAD_ADD_ADMIN
    case THREAD_REMOVE_ADMIN
    case THREAD_ADD_PARTICIPANTS        // type 11
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

public enum MessageEventTypes {
    case MESSAGE_NEW        // type 2
    case MESSAGE_SEND       // type 3
    case MESSAGE_DELIVERY   // type 4
    case MESSAGE_SEEN       // type 5
    case MESSAGE_EDIT       // type 28
    case MESSAGE_DELETE     // type 29
}

public enum FileUploadEventTypes {
    case NOT_STARTED        //
    case UPLOADING          //
    case UPLOADED           //
    case UPLOAD_ERROR       //
//    case UPLOAD_CANCELED    //
}

public enum SystemEventTypes {
    case SERVER_TIME
    case IS_TYPING
    case STOP_TYPING
}


public enum BotEventTypes {
    case BOT_MESSAGE
}


