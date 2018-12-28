//
//  ObjectTypes.swift
//  Chat
//
//  Created by Mahyar Zhiani on 6/10/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//
//
//import Foundation
//import SwiftyJSON




/*
 
 struct AsyncMessageContentToSend {
 var peerName:   String
 var priority:   Int
 var content:    String
 var ttl:        Int
 
 func returnJSON() -> JSON {
 var json: JSON = []
 json.appendIfDictionary(key: "peerName", json: JSON(peerName))
 json.appendIfDictionary(key: "priority", json: JSON(priority))
 json.appendIfDictionary(key: "content", json: JSON(content))
 json.appendIfDictionary(key: "ttl", json: JSON(ttl))
 return json
 }
 
 func returnString() -> String {
 let myJSON: JSON = returnJSON()
 let myString: String = "\(myJSON)"
 return myString
 }
 
 }
 
 
 
 struct ChatMessageContentToSend {
 var token:          String  // token given by SSO
 var tokenIssuer:    Int     // it will be equal to 1
 var type:           Int     // type of Message type (from 30 cases)
 var subjectId:      Int?    //
 var uniqueId:       String  //
 var content:        String  // content of message in "\(JSON)"
 var time:           Int?    //
 var metadata:       String? //
 var systemMetadata: String? //
 var repliedTo:      Int?    //
 
 func returnJSON() -> JSON {
 var json: JSON = []
 json.appendIfDictionary(key: "token", json: JSON(token))
 json.appendIfDictionary(key: "tokenIssuer", json: JSON(tokenIssuer))
 json.appendIfDictionary(key: "type", json: JSON(type))
 json.appendIfDictionary(key: "uniqueId", json: JSON(uniqueId))
 json.appendIfDictionary(key: "content", json: JSON(content))
 if let thrSubjectId = subjectId {
 json.appendIfDictionary(key: "subjectId", json: JSON(thrSubjectId))
 }
 if let theTime = time {
 json.appendIfDictionary(key: "time", json: JSON(theTime))
 }
 if let theMetadata = metadata {
 json.appendIfDictionary(key: "metadata", json: JSON(theMetadata))
 }
 if let theSystemMetadata = systemMetadata {
 json.appendIfDictionary(key: "systemMetadata", json: JSON(theSystemMetadata))
 }
 if let theRepliedTo = repliedTo {
 json.appendIfDictionary(key: "repliedTo", json: JSON(theRepliedTo))
 }
 return json
 }
 
 func returnString() -> String {
 let myJSON: JSON = returnJSON()
 let myString: String = "\(myJSON)"
 return myString
 }
 
 }
 
 
 struct GetUserInfoContentSend {
 func returnString() -> String {
 return ""
 }
 }
 
 // content in ChatMessage for GET_THREADS
 struct GetThreadsContentSend {
 
 var count:      Int?    // count of threads to receive
 var offset:     Int?    // offset for list of theads
 var name:       String? // find threads like given name
 var threadIds:  [Int]?  // array of thread ids
 var new:        Bool?   // find threads that have unseen message
 
 func returnJSON() -> JSON {
 var json: JSON = []
 if let theCount = count {
 json.appendIfDictionary(key: "count", json: JSON(theCount))
 }
 if let theOffset = offset {
 json.appendIfDictionary(key: "offset", json: JSON(theOffset))
 }
 if let theName = name {
 json.appendIfDictionary(key: "name", json: JSON(theName))
 }
 if let theThreadIds = threadIds {
 for item in theThreadIds {
 json.appendIfDictionary(key: "threadIds", json: JSON(item))
 }
 }
 if let theNew = new {
 json.appendIfDictionary(key: "new", json: JSON(theNew))
 }
 return json
 }
 
 func returnString() -> String {
 let theJSON = returnJSON()
 let myString = "\(theJSON)"
 return myString
 }
 
 }
 
 
 // content in ChatMessage for GET_HISTORY
 struct GetHistoryContentSend {
 
 var count:          Int?    // count of threads to receive
 var offset:         Int?    // offset for list of threads
 var order:          String? // [asc:desc] change sort order of messages (default = desc)
 var threadId:       Int
 //    var firstMesssageId:Int?    // filter messages with id >= value
 //    var lastMesssageId: Int?    // filter messages with id <= value
 
 func returnJSON() -> JSON {
 var json: JSON = []
 json.appendIfDictionary(key: "threadId", json: JSON(threadId))
 if let theCount = count {
 json.appendIfDictionary(key: "count", json: JSON(theCount))
 }
 if let theOffset = offset {
 json.appendIfDictionary(key: "offset", json: JSON(theOffset))
 }
 if let theOrder = order {
 json.appendIfDictionary(key: "order", json: JSON(theOrder))
 }
 //        if let theFirstMesssageId = firstMesssageId {
 //            json.appendIfDictionary(key: "firstMesssageId", json: JSON(theFirstMesssageId))
 //        }
 //        if let theLastMesssageId = lastMesssageId {
 //            json.appendIfDictionary(key: "lastMesssageId", json: JSON(theLastMesssageId))
 //        }
 return json
 }
 
 func returnString() -> String {
 let theJSON = returnJSON()
 let myString = "\(theJSON)"
 return myString
 }
 
 }
 
 
 struct GetThreadParticipantsContentSend {
 var count:      Int?
 var offset:     Int?
 var threadId:   Int
 
 func returnJSON() -> JSON {
 var json: JSON = []
 json.appendIfDictionary(key: "threadId", json: JSON(threadId))
 if let theCount = count {
 json.appendIfDictionary(key: "count", json: JSON(theCount))
 }
 if let theOffset = offset {
 json.appendIfDictionary(key: "offset", json: JSON(theOffset))
 }
 return json
 }
 
 func returnString() -> String {
 let theJSON = returnJSON()
 let myString = "\(theJSON)"
 return myString
 }
 
 }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 struct Conversation {
 var id:                             Int                 // id of thraad
 var title:                          String              // title (name) of thread (in pv will be name of partner)
 var participants:                   [ParticipantVO]?    // array of ParticipantVO type
 var time:                           Int
 var lastMessage:                    String              // text of last message
 var lastParticipantName:            String              // participant name of last message
 var group:                          Bool                // is group thread or not
 var partner:                        Int                 // fill in pv: participant id of partner
 var image:                          ImageInfo           // image of thrad (in groups it will be image of last participant and in pv will be image of partner)
 var unreadCount:                    Int                 // count of unread messages
 var lastMessageVO:                  Message             // last Message
 var partnerLastMessageId:           Int                 // fill in pv: id of last message delivered to partner
 var partnerLastDeliveredMessageId:  Int                 // fill in pv: id of last message that partner seen
 var type:                           Int                 // type of thread
 var metadata:                       String              // metadata of thread
 var mute:                           Bool                // is thread mute
 var participantCount:               Int                 // count of participants
 }
 struct ParticipantVO {
 
 }
 struct ImageInfo {
 
 }
 
 struct Message {
 var id:             Int         // id of message
 var uniqueId:       String      // tracker id of message
 var previousId:     Int         // id of previous message in thead
 var message:        String      // text of message
 var participant:    Participant // sender of message (will fill based on thread type)
 var time:           Int         // time of message
 var metadata:       String      // metadata of message
 var replyInfoVO:    ReplyInfo
 var forwardInfo:    ForwardInfo
 }
 struct Participant {
 var id:     Int         // id of participant (fill innone channel)
 var name:   String      //name of participant
 var image:  ImageInfo   // image of participant (fill in none channel)
 }
 struct ReplyInfo {
 var participant:        Participant // sender of replied message
 var repliedToMessageId: Int         // id of replies message
 var repliedToMessage:   String      // cropped text of replied message
 }
 struct ForwardInfo {
 var participant:    Participant         // message sender (fill if not channel)
 var conversation:   ConversationSummery // summery for thread of forwarded message
 }
 struct ConversationSummery {
 var id:         Int     // id of thread
 var title:      String  // title (name) of thrad (in pv will be name of partner)
 var metadata:   String  // metadata of thread
 }
 
 
 
 
 
 
 
 
 
 
 
 struct GetUserInfoReceive {
 var hasError:       Bool
 var errorMessage:   String
 var errorCode:      Int
 var result:         User
 func getUserInfoAsJSON() -> JSON {
 let user: JSON = result.getUserAsJSON()
 let userResult: JSON = ["user": user]
 let value: JSON = ["hasError": hasError,
 "errorMessage": errorMessage,
 "errorCode": errorCode,
 "result": userResult]
 return value
 }
 func getUserInfoAsStringOfJSON() -> String {
 let infoJSON: JSON = getUserInfoAsJSON()
 let infoString: String = "\(infoJSON)"
 return infoString
 }
 }
 struct User {
 var id:             Int
 var name:           String
 var email:          String
 var cellPhoneNumber:String
 var image:          String
 var lastSeen:       Int
 var sendEnable:     Bool
 var receiveEnable:  Bool
 func getUserAsJSON() -> JSON {
 let userJSON: JSON = ["id": id,
 "name": name,
 "email": email,
 "cellPhoneNumber": cellPhoneNumber,
 "image": image,
 "lastSeen": lastSeen,
 "sendEnable": sendEnable,
 "receiveEnable": receiveEnable]
 return userJSON
 }
 }
 
 */



















/*
 
 
 struct GetThreadsReceive {
 var hasError:       Bool
 var errorMessage:   String
 var errorCode:      Int
 var contentCount:   Int
 var hasNext:        Bool
 var nextOffset:     Int
 var result:         [Threads]
 func getThreadAsJSON() -> JSON {
 var threadArr: [JSON] = []
 for item in result {
 let theThread: JSON = item.threadsAsJSON()
 threadArr.append(theThread)
 }
 let threadResult: JSON = ["threads": threadArr]
 let getThreadJSON: JSON = ["hasError": hasError,
 "errorMessage": errorMessage,
 "errorCode": errorCode,
 "contentCount": contentCount,
 "hasNext": hasNext,
 "nextOffset": nextOffset,
 "result": threadResult]
 return getThreadJSON
 }
 func getThreadAsStringOfJSON() -> String {
 let threadJSON: JSON = getThreadAsJSON()
 let threadString: String = "\(threadJSON)"
 return threadString
 }
 }
 struct Threads {
 var id:                 Int             // id of thraad
 var joinDate:           Int
 var title:              String          // title (name) of thread (in pv will be name of partner)
 var participants:       Any             // array of ParticipantVO type
 var time:               Int
 var lastMessage:        String          // text of last message
 var lastParticipantName:String          // participant name of last message
 var group:              Bool            // is group thread or not
 var partner:            Int             // fill in pv: participant id of partner
 var image:              Any             // image of thrad (in groups it will be image of last participant and in pv will be image of partner)
 var unreadCount:        Int             // count of unread messages
 var lastSeenMessageId:  Int
 var lastMessageVO:      Any
 var partnerLastSeenMessageId:   Any
 var partnerLastDelivereMessageId:Any
 var type:               Int
 var metadata:           Any
 var mute:               Bool
 var participantCount:   Bool
 var canEditInfo:        Bool
 var inviter:            Inviter
 func threadsAsJSON() -> JSON {
 let myInviter: JSON = inviter.getInviterAsJSON()
 let inviterResult: JSON = ["user": myInviter]
 let threadJSON: JSON = ["id": id,
 "joinDate": joinDate,
 "title": title,
 "participants": participants,
 "time": time,
 "lastMessage": lastMessage,
 "lastParticipantName": lastParticipantName,
 "group": group,
 "partner": partner,
 "image": image,
 "unreadCount": unreadCount,
 "lastSeenMessageId": lastSeenMessageId,
 "lastMessageVO": lastMessageVO,
 "partnerLastSeenMessageId": partnerLastSeenMessageId,
 "partnerLastDelivereMessageId": partnerLastDelivereMessageId,
 "type": type,
 "metadata": metadata,
 "mute": mute,
 "participantCount": participantCount,
 "canEditInfo": canEditInfo,
 "inviter": inviterResult]
 return threadJSON
 }
 }
 struct Inviter {
 var id:             Int
 var sendEnable:     Bool
 var receiveEnable:  Bool
 var name:           String
 var myFriend:       Any
 var online:         Any
 var notSeenDuration:Int
 var image:          Any
 func getInviterAsJSON() -> JSON {
 let inviterJSON: JSON = ["id": id,
 "sendEnable": sendEnable,
 "receiveEnable": receiveEnable,
 "name": name,
 "myFriend": myFriend,
 "online": online,
 "notSeenDuration": notSeenDuration,
 "image": image]
 return inviterJSON
 }
 }
 
 
 
 
 
 
 
 
 
 
 struct GetHistoryReceive {
 var hasError:       Bool
 var errorMessage:   String
 var errorCode:      Int
 var contentCount:   Int
 var hasNext:        Bool
 var nextOffset:     Int
 var result:         [History]
 func getHistoryAsJSON() -> JSON {
 var historyArr: [JSON] = []
 for item in result {
 let theHistory: JSON = item.getHistoryAsJSON()
 historyArr.append(theHistory)
 }
 let historyResult: JSON = ["history": historyArr]
 let getHistoryJSON: JSON = ["hasError": hasError,
 "errorMessage": errorMessage,
 "errorCode": errorCode,
 "contentCount": contentCount,
 "hasNext": hasNext,
 "nextOffset": nextOffset,
 "result": historyResult]
 return getHistoryJSON
 }
 func getHistoryAsStringOfJSON() -> String {
 let historyJSON: JSON = getHistoryAsJSON()
 let historyStr: String = "\(historyJSON)"
 return historyStr
 }
 }
 struct History {
 var id:             Int
 var threadId:       Int
 var ownerId:        Int
 var uniqueId:       String
 var previousId:     Int
 var message:        String
 var edited:         Bool
 var editable:       Bool
 var delivered:      Bool
 var seen:           Any
 var conversation:   Any
 var replyInfo:      Any
 var forwardInfo:    Any
 var time:           Int
 var metadata:       Any
 var systemMetadata: Any
 var participant:    Participants
 func getHistoryAsJSON() -> JSON {
 let participantJSON: JSON = participant.getParticipantsAsJSON()
 let historyJSON: JSON = ["id": id,
 "threadId": threadId,
 "ownerId": ownerId,
 "uniqueId": uniqueId,
 "previousId": previousId,
 "message": message,
 "edited": edited,
 "editable": editable,
 "delivered": delivered,
 "seen": seen,
 "conversation": conversation,
 "replyInfo": replyInfo,
 "forwardInfo": forwardInfo,
 "time": time,
 "metadata": metadata,
 "systemMetadata": systemMetadata,
 "participant": participantJSON]
 return historyJSON
 }
 }
 struct Participants {
 var id:             Int
 var sendEnable:     Bool
 var receiveEnable:  Bool
 var name:           String
 var myFriend:       Any
 var online:         Any
 var notSeenDuration:Int
 var userId:         Any
 var image:          Any
 func getParticipantsAsJSON() -> JSON {
 let participantJSON: JSON = ["id": id,
 "sendEnable": sendEnable,
 "receiveEnable": receiveEnable,
 "name": name,
 "myFriend": myFriend,
 "online": online,
 "notSeenDuration": notSeenDuration,
 "userId": userId,
 "image": image]
 return participantJSON
 }
 }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 struct GetThreadParticipantsReceive {
 var hasError:       Bool
 var errorMessage:   String
 var errorCode:      Int
 var contentCount:   Int
 var hasNext:        Bool
 var nextOffset:     Int
 var result:         [Participants]
 func getThreadParticipantsAsJSON() -> JSON {
 var participantsArr: [JSON] = []
 for item in result {
 let theParticipant: JSON = item.getParticipantsAsJSON()
 participantsArr.append(theParticipant)
 }
 let participantsResult: JSON = ["participants": participantsArr]
 let getParticipantsJSON: JSON = ["hasError": hasError,
 "errorMessage": errorMessage,
 "errorCode": errorCode,
 "contentCount": contentCount,
 "hasNext": hasNext,
 "nextOffset": nextOffset,
 "result": participantsResult]
 return getParticipantsJSON
 }
 func getThreadParticipantsAsStringOfJSON() -> String {
 let threadParticipantJSON: JSON = getThreadParticipantsAsJSON()
 let threadParticipantStr: String = "\(threadParticipantJSON)"
 return threadParticipantStr
 }
 }
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 struct GetContactsReceive {
 var hasError:       Bool
 var errorMessage:   String
 var errorCode:      Int
 var contentCount:   Int
 var hasNext:        Bool
 var nextOffset:     Int
 var result:         [Contact]
 func getContactsAsJSON() -> JSON {
 var contactsArr: [JSON] = []
 for item in result {
 let theContact: JSON = item.getContactAsJSON()
 contactsArr.append(theContact)
 }
 let contactsResult: JSON = ["contacts": contactsArr]
 let getContactsJSON: JSON = ["hasError": hasError,
 "errorMessage": errorMessage,
 "errorCode": errorCode,
 "contentCount": contentCount,
 "hasNext": hasNext,
 "nextOffset": nextOffset,
 "result": contactsResult]
 return getContactsJSON
 }
 func getContactsAsStringOfJSON() -> String {
 let contactsJSON: JSON = getContactsAsJSON()
 let contactsStr: String = "\(contactsJSON)"
 return contactsStr
 }
 }
 struct Contact {
 var id:             Int
 var firstName:      String
 var lastName:       String
 var email:          String
 var cellPhoneNumber:String
 var uniqueId:       String
 var lastSeen:       Int
 var hasUser:        Bool
 func getContactAsJSON() -> JSON {
 let contactJSON: JSON = ["id": id,
 "firstName": firstName,
 "lastName": lastName,
 "email": email,
 "cellPhoneNumber": cellPhoneNumber,
 "uniqueId": uniqueId,
 "lastSeen": lastSeen,
 "hasUser": hasUser]
 return contactJSON
 }
 }
 
 
 
 
 */











































