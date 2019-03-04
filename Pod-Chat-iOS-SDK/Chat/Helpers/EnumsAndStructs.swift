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
    case RENAME                             = 10
    case ADD_PARTICIPANT                    = 11
    case GET_STATUS                         = 12
    case GET_CONTACTS                       = 13
    case GET_THREADS                        = 14
    case GET_HISTORY                        = 15
    case CHANGE_TYPE                        = 16
    case REMOVED_FROM_THREAD                = 17
    case REMOVE_PARTICIPANT                 = 18
    case MUTE_THREAD                        = 19
    case UNMUTE_THREAD                      = 20
    case UPDATE_THREAD_INFO                 = 21
    case FORWARD_MESSAGE                    = 22
    case USER_INFO                          = 23
    case USER_STATUS                        = 24
    case GET_BLOCKED                        = 25
    case RELATION_INFO                      = 26
    case THREAD_PARTICIPANTS                = 27
    case EDIT_MESSAGE                       = 28
    case DELETE_MESSAGE                     = 29
    case THREAD_INFO_UPDATED                = 30
    case LAST_SEEN_UPDATED                  = 31
    case GET_MESSAGE_DELEVERY_PARTICIPANTS  = 32
    case GET_MESSAGE_SEEN_PARTICIPANTS      = 33
    case BOT_MESSAGE                        = 40
    case SPAM_PV_THREAD                     = 41
    case LOGOUT                             = 100
    case ERROR                              = 999
}


public enum InviteeVOidTypes: Int {
    case TO_BE_USER_SSO_ID              = 1
    case TO_BE_USER_CONTACT_ID          = 2
    case TO_BE_USER_CELLPHONE_NUMBER    = 3
    case TO_BE_USER_USERNAME            = 4
    case TO_BE_USER_ID                  = 5
}


public enum ThreadTypes: String {
    case NORMAL         = "NORMAL"
    case OWNER_GROUP    = "OWNER_GROUP"
    case PUBLIC_GROUP   = "PUBLIC_GROUP"
    case CHANNEL_GROUP  = "CHANNEL_GROUP"
    case CHANNEL        = "CHANNEL"
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





public enum UserEventTypes {
    case userInfo
}


public enum MessageEventTypes/*: String*/ {
    case delivery   //= "Delivery"
    case seen       //= "Seen"
    case delete     //= "Delete"
    case new        //= "New"
    case edit       //= "Edit"
}


public enum ThreadEventTypes/*: String*/ {
    case getThreads
    case getHistory
    case getThreadParticipants
    case UpdateThreadInfo
    case new                  //= "Thread_New"
    case leaveParticipant     //= "Thread_Leave_Participant"
    case addParticipant       //= "Thread_Add_Participant"
    case removeParticipant    //= "Thread_Remove_Participant"
    case mute                 //= "Thread_Mute"
    case unmute               //= "Thread_Unmute"
    case infoUpdated          //= "Thread_Info_Updated"
    case removedFrom          //= "Thread_Removed_From"
    case unreadCountUpdate    //= "Thread_Unread_Count_Update"
    case lastActivityTime     //= "Thread_Last_Activity_Time"
}

public enum ContactEventTypes {
    case getContact
    case addContact
    case removeContact
    case blockContact
    case unblockContact
    
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






