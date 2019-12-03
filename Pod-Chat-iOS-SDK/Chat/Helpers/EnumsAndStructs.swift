//
//  Helpers.swift
//  Chat
//
//  Created by Mahyar Zhiani on 6/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation


enum myNotificationsKeys {
    case GetUserInfo
    
}

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
    case CLEAR_HISTORY                      = 44
    case SYSTEM_MESSAGE                     = 46
    case GET_NOT_SEEN_DURATION              = 47
    case GET_THREAD_ADMINS                  = 48    // it has been deprecated! (actualy has not been implemented yet! and won't be!!)
    case LOGOUT                             = 100
    case ERROR                              = 999
}


public enum INVITEE_VO_ID_TYPES {
    
    case TO_BE_USER_SSO_ID
    case TO_BE_USER_CONTACT_ID
    case TO_BE_USER_CELLPHONE_NUMBER
    case TO_BE_USER_USERNAME
    case TO_BE_USER_ID
    
    public func stringValue() -> String {
        switch self {
        case .TO_BE_USER_SSO_ID:            return "TO_BE_USER_SSO_ID"
        case .TO_BE_USER_CONTACT_ID:        return "TO_BE_USER_CONTACT_ID"
        case .TO_BE_USER_CELLPHONE_NUMBER:  return "TO_BE_USER_CELLPHONE_NUMBER"
        case .TO_BE_USER_USERNAME:          return "TO_BE_USER_USERNAME"
        case .TO_BE_USER_ID:                return "TO_BE_USER_ID"
        }
    }
    
    public func intValue() -> Int {
        switch self {
        case .TO_BE_USER_SSO_ID:            return 1
        case .TO_BE_USER_CONTACT_ID:        return 2
        case .TO_BE_USER_CELLPHONE_NUMBER:  return 3
        case .TO_BE_USER_USERNAME:          return 4
        case .TO_BE_USER_ID:                return 5
        }
    }
    
}

public enum ThreadTypes: String {
    case NORMAL                 = "NORMAL"
    case OWNER_GROUP            = "OWNER_GROUP"
    case PUBLIC_GROUP           = "PUBLIC_GROUP"
    case CHANNEL_GROUP          = "CHANNEL_GROUP"
    case CHANNEL                = "CHANNEL"
    case NOTIFICATION_CHANNEL   = "NOTIFICATION_CHANNEL"
}

public struct SERVICE_ADDRESSES_ENUM {
    public var SSO_ADDRESS          = "http://172.16.110.76"
    public var PLATFORM_ADDRESS     = "http://172.16.106.26:8080/hamsam"
    public var FILESERVER_ADDRESS   = "http://172.16.106.26:8080/hamsam"
    public var MAP_ADDRESS          = "https://api.neshan.org/v1"
}

public enum SERVICES_PATH: String {
    
    // Devices:
    case SSO_DEVICES        = "/oauth2/grants/devices"
    case SSO_GENERATE_KEY   = "/handshake/users/"
    case SSO_GET_KEY        = "/handshake/keys/"
    
    // Contacts:
    case ADD_CONTACTS       = "/nzh/addContacts"
    case UPDATE_CONTACTS    = "/nzh/updateContacts"
    case REMOVE_CONTACTS    = "/nzh/removeContacts"
    case SEARCH_CONTACTS    = "/nzh/listContacts"
    
    // File/Image Upload and Download
    case UPLOAD_IMAGE       = "/nzh/uploadImage"
    case GET_IMAGE          = "/nzh/image/"
    case UPLOAD_FILE        = "/nzh/uploadFile"
    case GET_FILE           = "/nzh/file/"
    
    // PodDrive
    case DRIVE_UPLOAD_FILE          = "/nzh/drive/uploadFile"
    case DRIVE_UPLOAD_FILE_FROM_URL = "/nzh/drive/uploadFileFromUrl"
    case DRIVE_UPLOAD_IMAGE         = "/nzh/drive/uploadImage"
    case DRIVE_DOWNLOAD_FILE        = "/nzh/drive/downloadFile"
    case DRIVE_DOWNLOAD_IMAGE       = "/nzh/drive/downloadImage"
    
    // Neshan Map
    case REVERSE            = "/reverse"
    case SEARCH             = "/search"
    case ROUTING            = "/routing"
    case STATIC_IMAGE       = "/static"
    
}

public enum CHAT_ERRORS: String {
    
    // Socket Errors
    case err6000 = "No Active Device found for this Token!"
    case err6001 = "Invalid Token!"
    case err6002 = "User not found!"
    
    // Get User Info Errors
    case err6100 = "Cant get UserInfo!"
    case err6101 = "Getting User Info Retry Count exceeded 5 times; Connection Can Not Estabilish!"
    
    // Http Request Errors
    case err6200 = "Network Error"
    case err6201 = "URL is not clarified!"
    
    // File Uploads Errors
    case err6300 = "Error in uploading File!"
    case err6301 = "Not an image!"
    case err6302 = "No file has been selected!"
    
    // Map Errors
    case err6700 = "You should Enter a Center Location like {lat: \" \", lng: \" \"}"
}

public enum asyncStateTypes: String {
    case type0  = "CONNECTING"
    case type1  = "CONNECTED"
    case type2  = "CLOSING"
    case type3  = "CLOSED"
}


/*
public enum UserEventTypes {
    case userInfo           // type 23
}
*/

public enum ContactEventTypes {
    case CONTACTS_LIST_CHANGE   //
    case CONTACTS_SEARCH_RESULT_CHANGE  //
    
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
    case THREAD_NEW                     // type 1
    case THREAD_LEAVE_PARTICIPANT       // type 9
    case THREAD_LAST_ACTIVITY_TIME      //
    case THREAD_ADD_PARTICIPANTS        // type 11
    case THREAD_REMOVED_FROM            // type 17
    case THREAD_REMOVE_PARTICIPANTS     // type 18
    case THREAD_MUTE                    // type 19
    case THREAD_UNMUTE                  // type 20
    case THREAD_INFO_UPDATED            // type 21
    case THREAD_UNREAD_COUNT_UPDATED    // type 31
    case THREADS_LIST_CHANGE            //
    case THREAD_PARTICIPANTS_LIST_CHANGE//
    
    /*
//    case CreateThread           // type 1
//    case LeaveThread            // type 9
//    case AddParticipant         // type 11
    case GetThreads             // type 14
    case GetHistory             // type 15
//    case RemovedFromThread      // type 17
//    case RemoveParticipant      // type 18
//    case Mute                   // type 19
//    case Unmute                 // type 20
//    case UpdateThreadInfo       // type 21
    case ThreadInfoUpdated      // type 30
    case GetThreadParticipants          // type 27
//    case LastSeenUpdated                // type 31
    case GetMessageDeliveryParticipants // type 32
    case GetMessageSeenParticipants     // type 33
    case SpamPvThread           // type 41
    case SetRoleToUser          // type 42
    case ClearHistory           // type 44
    case SignalMessage          // type 46
    
    case leaveParticipant     //= "Thread_Leave_Participant"
    case infoUpdated          //= "Thread_Info_Updated"
    case removedFrom          //= "Thread_Removed_From"
    case unreadCountUpdate    //= "Thread_Unread_Count_Update"
    case lastActivityTime     //= "Thread_Last_Activity_Time"
    case isTyping
    */
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
    case UPLOAD_CANCELED    //
}

public enum SystemEventTypes {
    case IS_TYPING      //
}


public enum BotEventTypes {
    case BOT_MESSAGE    //
}


public enum SignalMessageType: Int {
    case IS_TYPING      = 1
    case RECORD_VOICE   = 2
    case UPLOAD_PICTURE = 3
    case UPLOAD_VIDEO   = 4
    case UPLOAD_SOUND   = 5
    case UPLOAD_FILE    = 6
}


public enum DownloaUploadAction {
    case cancel
    case suspend
    case resume
}



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


//let messageIdsList: [Int] = params["content"].arrayObject! as! [Int]
//var uniqueIdsList: [String] = []
//
//for _ in messageIdsList {
//    let content: JSON = ["content": params["content"].stringValue]
//    var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
//                                   "pushMsgType": 4,
//                                   "content": content]
//
//    if let threadId = params["subjectId"].int {
//        sendMessageParams["subjectId"] = JSON(threadId)
//    }
//    if let repliedTo = params["repliedTo"].int {
//        sendMessageParams["repliedTo"] = JSON(repliedTo)
//    }
//    if let uniqueId = params["uniqueId"].string {
//        sendMessageParams["uniqueId"] = JSON(uniqueId)
//    }
//    if let metaData = params["metaData"].arrayObject {
//        let metaDataStr = "\(metaData)"
//        sendMessageParams["metaData"] = JSON(metaDataStr)
//    }
//    sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(), deliverCallback: SendMessageCallbacks(), seenCallback: SendMessageCallbacks()) { (theUniqueId) in
//        uniqueIdsList.append(theUniqueId)
//    }
//
//    sendCallbackToUserOnSent = onSent
//    sendCallbackToUserOnDeliver = onDelivere
//    sendCallbackToUserOnSeen = onSeen
//
//}
//
//uniqueIds(uniqueIdsList)






