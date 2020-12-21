//
//  ChatPrivateMethods.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import FanapPodAsyncSDK
import Alamofire
import SwiftyJSON
import SwiftyBeaver
import Sentry

// MARK: -
// MARK: - Private Methods:

extension Chat {
    
    
    func checkIfDeviceHasFreeSpace(needSpaceInMB: Int64, turnOffTheCache: Bool) -> Bool {
        let availableSpace = DiskStatus.freeDiskSpaceInBytes
        if availableSpace < (needSpaceInMB * 1024 * 1024) {
            var message = "your disk space is less than \(DiskStatus.MBFormatter(DiskStatus.freeDiskSpaceInBytes))MB."
            if turnOffTheCache {
                message += " " + "so, the cache will be switch OFF!"
            }
            delegate?.chatError(errorCode: 6401, errorMessage: message, errorResult: nil)
            return false
        } else {
            return true
        }
    }
    
    /*
     *  Get deviceId with token:
     *
     *  + Access:
     *      - private
     *
     *  + Inputs:
     *      - this method has no prameters as input
     *
     *  + Outputs:
     *      - it will return the deviceId as a String as a callback
     */
    func getDeviceIdWithToken(completion: @escaping (String) -> ()) {
        /*
         *  -> send a .get request to ssoHost server to get all user registered devices
         *
         *  -> get response as String
         *  -> convert String to Data
         *  -> convert Data to JSON
         *      + JSON contains array of objects:
         *          - total:    Int
         *          - size:     Int
         *          - offset:   Int
         *          + devices:
         *              [
         *                  - agent:            String  (conrains user device details)
         *                  - browserVersion:   String  (ex: "Chrome")
         *                  - current:          Bool    (ex: false)
         *                  - deviceType:       String  (ex: "Desktop")
         *                  - id:               Int     (ex: 12209)
         *                  - ip:               String  (ex: "172.16.107.106")
         *                  - language:         String  (ex: "fa")
         *                  - lastAccessTime:   Int     (ex: 1548070459111)
         *                  + location:         {}
         *                  - os:               String  (ex: "Win10")
         *                  - osVersion:        String  (ex: "10.0")
         *                  - uid:              String  (ex: "a4c812ba4cea8b01bef58ac65c3a6094")
         *              ]
         *
         *  -> loop throuth the "devices" to find an object which its "current" value is equal to "true"
         *      (which means this is the current device that user is using right now)
         *      (actualy we have to find one object that has this condition)
         *  -> get the "uid" value from this object and pass it to the caller as completion
         *      (its the user deviceId)
         *
         *
         */
        
        let url = ssoHost + SERVICES_PATH.SSO_DEVICES.rawValue
        let method: HTTPMethod = .get
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        Alamofire.request(url, method: method, parameters: nil, headers: headers).responseString { (response) in
            
            // check if the result respons is success
            if response.result.isSuccess {
                let responseStr: String = response.result.value!
                // convert String to Data
                if let dataFromMsgString = responseStr.data(using: .utf8, allowLossyConversion: false) {
                    
                    var msg: JSON
                    if let jsonString = try? JSON(data: dataFromMsgString) {
                        msg = jsonString
                    } else {
                        self.asyncError(errorCode: 1000,
                                        errorMessage: "cannot convert StringData to JSON on 'getDeviceIdWithToken' methodResponse",
                                        errorEvent: nil)
                        return
                    }
//                    do {
//                        // convert Data to JSON
//                        msg = try JSON(data: dataFromMsgString)
//                    } catch {
//                        fatalError("Cannot convert Data to JSON")
//                    }
                    
                    // loop through devices
                    if let devices = msg["devices"].array {
                        for device in devices {
                            // check if we can found user current device
                            if device["current"].bool == true {
                                completion(device["uid"].stringValue)
                                break
                            }
                        }
                        if (self.deviceId == nil || (self.deviceId == "")) {
                            // if deviceId is nil, we will send an Error Event to client
                            self.delegate?.chatError(errorCode:     6000,
                                                     errorMessage:  ChatErrors.err6000.stringValue(),
                                                     errorResult:   nil)
                        }
                    } else {
                        // if server response has no array value of devices, we will send an Error Event to client
                        self.delegate?.chatError(errorCode:     6001,
                                                 errorMessage:  ChatErrors.err6001.stringValue(),
                                                 errorResult:   nil)
                    }
                    
                }
                
            } else if let error = response.error {
                log.error("Response of getDeviceIdWithToken is Failed)", context: "Chat")
                self.delegate?.chatError(errorCode:     6200,
                                         errorMessage:  "\(ChatErrors.err6200.stringValue()): \(error)",
                                         errorResult:   error.localizedDescription)
            }
        }
        
    }
    

    /*
     *  Handshake with SSO to get user's keys:
     *
     * get the key (for Encrypt and Decrypt the Cache) from SSO
     *
     *  + Access:
     *      - private
     *
     *  + Inputs:
     *      - keyAlgorithm: String?
     *      - keySize:      Int?
     *
     *  + Outputs:
     *      - JSON (as completion handler)
     *
     */
    // TODO: save the new key into the Cache
    func generateEncryptionKey(keyAlgorithm: String?, keySize: Int?, completion: @escaping (JSON)->()) {
        /*
         *  -> send a .post request to the SSO server to generate and then get the key
         *
         *  -> get response as String
         *  -> convert String to Data
         *  -> convert Data to JSON
         *      + JSON contains this object:
         *          - algorithm:            String  (ex: "AES")
         *          - expires_in:           Int     (ex: 315360000)
         *          - keyFormat:            String  (ex: "base64")
         *          - keyId:                String  (ex: "18294d3013f61562669359")
         *          - secretKey:            String  (ex: "8nBxSBvghRaBpwPH8ZbA1bqUa7K\/Hbr5EH5Ab1WSJJY=")
         *          + device:
         *              - agent:            String  (ex: "Mozilla\/5.0 (X11; Linux x86_64) Appl ....")
         *              - browser:          String  (ex: "Chrome")
         *              - browserVersion:   String  (ex: "59")
         *              - current:          Bool    (ex: false)
         *              - deviceType:       String  (ex: "Desktop")
         *              - id:               Int     (ex: 10368)
         *              - ip:               String  (ex: "172.16.106.42")
         *              - lastAccessTime:   Int     (ex: 1551613854000)
         *              + location:         {}
         *              - os:               String  (ex: "Linux")
         *              - uid:              String  (ex: "94af0c8f381deeb7aa28a85c473641c1-Reza")
         *          + user:
         *              - family_name:          String  (ex: "Reza")
         *              - given_name:           String  (ex: "Irani")
         *              - id:                   Int     (ex: 5098)
         *              - preferred_username:   String  (ex: "Reza")
         *
         */
        
        let url = SERVICE_ADDRESSES.SSO_ADDRESS + SERVICES_PATH.SSO_GENERATE_KEY.rawValue
        let method: HTTPMethod = .post
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: Parameters = ["validity":       10 * 365 * 24 * 60 * 60,      // 10 years
                                  "renew":          "true",
                                  "keyAlgorithm":   keyAlgorithm ?? "aes",
                                  "keySize":        keySize ?? 256]
        
        Alamofire.request(url, method: method, parameters: params, headers: headers).responseString { (response) in
            
            if response.result.isSuccess {
                let responseStr: String = response.result.value!
                // convert String to Data
                if let dataFromMsgString = responseStr.data(using: .utf8, allowLossyConversion: false) {
                    
                    var msg: JSON
                    if let jsonString = try? JSON(data: dataFromMsgString) {
                        msg = jsonString
                    } else {
                        self.asyncError(errorCode: 1000,
                                        errorMessage: "cannot convert StringData to JSON on 'generateEncryptionKey' methodResponse",
                                        errorEvent: nil)
                        return
                    }
//                    do {
//                        // convert Data to JSON
//                        msg = try JSON(data: dataFromMsgString)
//                    } catch {
//                        fatalError("Cannot convert Data to JSON")
//                    }
                    
                    let myJson: JSON = ["hasError":     false,
                                        "errorCode":    0,
                                        "errorMessage": "",
                                        "result":       msg]
                    
                    // TODO: here we have to save the new KeyId in the Cache and update the cahceSecret
                    
                    completion(myJson)
                }
                
            } else if let error = response.error {
                self.delegate?.chatError(errorCode:     6200,
                                         errorMessage:  "\(ChatErrors.err6200.stringValue()): \(error)",
                    errorResult:   error.localizedDescription)
                
                let myJson: JSON = ["hasError":     true,
                                    "errorCode":    6200,
                                    "errorMessage": "\(ChatErrors.err6200.stringValue()) \(error)",
                                    "errorEvent":   error.localizedDescription]
                completion(myJson)
            }
        
        }

    }
    
    
    /*
     * Get Encryption Keys by KeyId:
     *
     * get the key (for Encrypt and Decrypt the Cache) from SSO by sending KeyId
     *
     *  + Access:
     *      - private
     *
     *  + Inputs:
     *      - keyAlgorithm: String?
     *      - keySize:      Int?
     *      - keyId:        String
     *
     *  + Outputs:
     *      - JSON (as completion handler)
     *
     */
    func getEncryptionKey(keyAlgorithm: String?, keySize: String?, keyId: String, completion: @escaping (JSON)->()) {
        /*
         *  -> send a .get request to the SSO server to get the secretKey with keyId
         *
         *  -> get response as String
         *  -> convert String to Data
         *  -> convert Data to JSON
         *      + JSON contains this object:
         *          - algorithm:            String  (ex: "AES")
         *          - expires_in:           Int     (ex: 315360000)
         *          - keyFormat:            String  (ex: "base64")
         *          - keyId:                String  (ex: "18294d3013f61562669359")
         *          - secretKey:            String  (ex: "8nBxSBvghRaBpwPH8ZbA1bqUa7K\/Hbr5EH5Ab1WSJJY=")
         *          + device:
         *              - agent:            String  (ex: "Mozilla\/5.0 (X11; Linux x86_64) Appl ....")
         *              - browser:          String  (ex: "Chrome")
         *              - browserVersion:   String  (ex: "59")
         *              - current:          Bool    (ex: false)
         *              - deviceType:       String  (ex: "Desktop")
         *              - id:               Int     (ex: 10368)
         *              - ip:               String  (ex: "172.16.106.42")
         *              - lastAccessTime:   Int     (ex: 1551613854000)
         *              + location:         {}
         *              - os:               String  (ex: "Linux")
         *              - uid:              String  (ex: "94af0c8f381deeb7aa28a85c473641c1-Reza")
         *          + user:
         *              - family_name:          String  (ex: "Reza")
         *              - given_name:           String  (ex: "Irani")
         *              - id:                   Int     (ex: 5098)
         *              - preferred_username:   String  (ex: "Reza")
         *          + client:
         *              + allowedGrantTypes:    []      (ex: ["authorization_code", "refresh_token", "implicit"])
         *              + allowedScopes:        []      (ex: ["phone", "legal_nationalcode", "activity", ...])
         *              + allowedRedirectUris:  []      (ex: ["*"])
         *              + allowedUserIPs:       []      (ex: ["*"])
         *              - captchaEnabled:       Bool    (ex: false)
         *              - client_id:            String  (ex: "dd5c454bb756c6de92c7cb15")
         *              - description:          String  (ex: "Keylead Root Client")
         *              - id:                   Int     (ex: 1)
         *              - loginUrl:             String  (ex: "http:\/\/podtest.fanapsoft.ir:8008\/oauth2\....")
         *              - name:                 String  (ex: "KeyleadFather")
         *              - signupEnabled:        Bool    (ex: true)
         *              - supportNumber:        String  (ex: "021-33255")
         *              - url:                  String  (ex: "http:\/\/keylead.fanapium.com")
         *              - userId:               Int     (ex: 1)
         *
         */
        // TODO: save the new keyId into the Cache
        let url = SERVICE_ADDRESSES.SSO_ADDRESS + SERVICES_PATH.SSO_GET_KEY.rawValue + "\(keyId)"
        let method: HTTPMethod = .get
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        let params: Parameters = ["validity":       10 * 365 * 24 * 60 * 60,  // 10 years
                                  "renew":          false,
                                  "keyAlgorithm":   keyAlgorithm ?? "aes",
                                  "keySize":        keySize ?? 256]
        
        Alamofire.request(url, method: method, parameters: params, headers: headers).responseString { (response) in
            
            if response.result.isSuccess {
                let responseStr: String = response.result.value!
                // convert String to Data
                if let dataFromMsgString = responseStr.data(using: .utf8, allowLossyConversion: false) {
                    
                    var msg: JSON
                    if let jsonString = try? JSON(data: dataFromMsgString) {
                        msg = jsonString
                    } else {
                        self.asyncError(errorCode: 1000,
                                        errorMessage: "cannot convert StringData to JSON on 'getEncryptionKey' methodResponse",
                                        errorEvent: nil)
                        return
                    }
//                    do {
//                        // convert Data to JSON
//                        msg = try JSON(data: dataFromMsgString)
//                    } catch {
//                        fatalError("Cannot convert Data to JSON")
//                    }
                    let myJson: JSON = ["hasError":     false,
                                        "errorCode":    0,
                                        "errorMessage": "",
                                        "result":       msg]
                    
                    // TODO: here we have to save the new KeyId in the Cache and update the cahceSecret
                    
                    completion(myJson)
                }
                
            } else if let error = response.error {
                self.delegate?.chatError(errorCode:     6200,
                                         errorMessage:  "\(ChatErrors.err6200.stringValue()): \(error)",
                    errorResult:   error.localizedDescription)
                
                let myJson: JSON = ["hasError":     true,
                                    "errorCode":    6200,
                                    "errorMessage": "\(ChatErrors.err6200.stringValue()) \(error)",
                                    "errorEvent":   error.localizedDescription]
                completion(myJson)
            }
            
        }

    }
    
    
    /*
     *
     *
     */
    func chatSendQueueHandler() {
        
    }
    
    
    func sendMessageWithCallback(asyncMessageVO:    SendAsyncMessageVO,
                                 callbacks:         [(call: CallbackProtocol, uniques: String)]?,
                                 sentCallback:      (call: CallbackProtocolWith3Calls, uniques: [String])?,
                                 deliverCallback:   (call: CallbackProtocolWith3Calls, uniques: [String])?,
                                 seenCallback:      (call: CallbackProtocolWith3Calls, uniques: [String])?) {
        
        let chatMessageVO = SendChatMessageVO(content: asyncMessageVO.content.convertToJSON())
        
        if let myCallbacks = callbacks {
            for item in myCallbacks {
                if (asyncMessageVO.content.convertToJSON()["chatMessageVOType"].intValue == 41) {
                    Chat.spamMap[item.uniques] = [item.call, item.call, item.call] //as? [CallbackProtocol]
                } else if let _ = item.call as? GetMentionCallbacks {
                    Chat.mentionMap[item.uniques] = item.call
                } else {
                    Chat.map[item.uniques] = item.call
                }
            }
        }
        if (sentCallback != nil) {
            for uId in sentCallback!.uniques {
                Chat.mapOnSent[uId] = sentCallback!.call
            }
        }
        if (deliverCallback != nil) {
            for uId in sentCallback!.uniques {
                let uniqueIdDic: [String: CallbackProtocolWith3Calls] = [uId: deliverCallback!.call]
                if Chat.mapOnDeliver["\(chatMessageVO.subjectId ?? 0)"] != nil {
                    Chat.mapOnDeliver["\(chatMessageVO.subjectId ?? 0)"]!.append(uniqueIdDic)
                } else {
                    Chat.mapOnDeliver["\(chatMessageVO.subjectId ?? 0)"] = [uniqueIdDic]
                }
            }
        }
        if (seenCallback != nil) {
            for uId in seenCallback!.uniques {
                let uniqueIdDic: [String: CallbackProtocolWith3Calls] = [uId: deliverCallback!.call]
                if Chat.mapOnSeen["\(chatMessageVO.subjectId ?? 0)"] != nil {
                    Chat.mapOnSeen["\(chatMessageVO.subjectId ?? 0)"]!.append(uniqueIdDic)
                } else {
                    Chat.mapOnSeen["\(chatMessageVO.subjectId ?? 0)"] = [uniqueIdDic]
                }
            }
        }
        
        log.verbose("map json: \n \(Chat.map)", context: "Chat")
        log.verbose("map onSent json: \n \(Chat.mapOnSent)", context: "Chat")
        log.verbose("map onDeliver json: \n \(Chat.mapOnDeliver)", context: "Chat")
        log.verbose("map onSeen json: \n \(Chat.mapOnSeen)", context: "Chat")
        
        let contentToSend = asyncMessageVO.convertModelToString()
        
        log.verbose("AsyncMessageContent of type JSON (to send to socket): \n \(contentToSend)", context: "Chat")
        
        if (chatMessageVO.chatMessageVOType == 0) {
            sendRequestToAsync(type: asyncMessageVO.pushMsgType ?? 3, content: contentToSend)
        } else {
            sendRequestHandler(type: asyncMessageVO.pushMsgType ?? 3, content: contentToSend)
        }
    }
    
    
    private func sendRequestHandler(type: Int, content: String) {
        if isChatReady {
            sendRequestToAsync(type: type, content: content)
        } else {
            sendRequestQueue.append((type: type, content: content))
        }
    }
    
    func sendRequestToAsync(type: Int, content: String) {
        asyncClient?.pushSendData(type: type, content: content)
        runSendMessageTimer()
    }
    
    
    /*
     * Run timer
     *
     * This Function will run the timer
     * if there is "chatPingMessageInterval" seconds that threre was no message sends through chat
     * it will send a ping message to keep user connected to chat
     *
     * + Access:    private
     * + Inputs:    nothing
     * + Outputs:   nothing
     *
     */
    func runSendMessageTimer() {
//        lastSentMessageTimer = nil
//        lastSentMessageTimer = RepeatingTimer(timeInterval: TimeInterval(self.chatPingMessageInterval))
        
        stopLastSentMessageTimer()
//        lastSentMessageTime = Date()
        lastSentMessageTimer(interval: TimeInterval(self.chatPingMessageInterval))
    }
    
    
    /*
     * Ping
     *
     * This Function sends ping message to keep the user connected to the chat server
     *
     * + Access:    private
     * + Inputs:    _
     * + Outputs:   _
     *
     */
    func ping() {
        /*
         *
         *  -> if chat is connected and we also have the peerId
         *  -> then send a message of type PING
         *      (Ping messages should be sent ASAP,
         *       because we don't want to wait for send queue,
         *       so we send them right through the async from here)
         *  -> then reset the value of the timer ("lastSentMessageTimeoutId")
         *
         */
        if (isChatReady == true && peerId != nil && peerId != 0) {
            
            log.verbose("Try to send Ping", context: "Chat")
            
            let chatMessage = SendChatMessageVO(chatMessageVOType: ChatMessageVOTypes.PING.intValue(),
                                                content:            nil,
                                                messageType:        nil,
                                                metadata:           nil,
                                                repliedTo:          nil,
                                                systemMetadata:     nil,
                                                subjectId:          nil,
                                                token:              token,
                                                tokenIssuer:        nil,
                                                typeCode:           nil,
                                                uniqueId:           nil,
                                                uniqueIds:          nil,
                                                isCreateThreadAndSendMessage: nil)
            
            let asyncMessage = SendAsyncMessageVO(content:      chatMessage.convertModelToString(),
                                                  msgTTL:       msgTTL,
                                                  peerName:     serverName,
                                                  priority:     msgPriority,
                                                  pushMsgType:  5)
            
            sendMessageWithCallback(asyncMessageVO:     asyncMessage,
                                    callbacks:          nil,
                                    sentCallback:       nil,
                                    deliverCallback:    nil,
                                    seenCallback:       nil)
            
//        } else if (lastSentMessageTimer != nil) {
//            lastSentMessageTimer?.suspend()
        } else {
            stopLastSentMessageTimer()
        }
    }
    
    
    /*
     * Received Message Handler:
     *
     * Handle recieve message from Async
     *
     *  + Message Received From Async    JSON
     *      - id:               Int
     *      - type:             Int
     *      - senderMessageId:  Int
     *      - senderName:       String
     *      - senderId:         Int
     *      - uniqueId:         String
     *      + content:              String(JSON)
     *          - contentCount:          Int
     *          - type:                  Int
     *          - uniqueId:              String
     *          - threadId:              Int
     *          - content:               String
     *
     */
    func receivedMessageHandler(withContent message: ChatMessage) {
        log.verbose("content of received message: \n \(message.returnToJSON())", context: "Chat")
        lastReceivedMessageTime = Date()
                
//        let messageContentAsString      = message.content
        let messageContentAsJSON: JSON  = message.content?.convertToJSON() ?? [:]
        
        switch message.type {
            
        // a message of type 1 (CREATE_THREAD) comes from Server.
        case ChatMessageVOTypes.CREATE_THREAD.intValue():
            responseOfCreateThread(withMessage: message)
            break
            
            // a message of type 2 (MESSAGE) comes from Server.
        // this means that a message comes.
        case ChatMessageVOTypes.MESSAGE.intValue():
            log.verbose("Message of type 'MESSAGE' recieved", context: "Chat")
//            chatMessageHandler(threadId: threadId, messageContent: messageContent)
            chatMessageHandler(threadId: message.subjectId ?? 0, messageContent: messageContentAsJSON)
            break
            
            // a message of type 3 (SENT) comes from Server.
        // it means that the message is send.
        case ChatMessageVOTypes.SENT.intValue():
            responseOfOnSendMessage(withMessage: message)
            break
            
            // a message of type 4 (DELIVERY) comes from Server.
        // it means that the message is delivered.
        case ChatMessageVOTypes.DELIVERY.intValue():
            responseOfOnDeliveredMessage(withMessage: message)
            break
            
            // a message of type 5 (SEEN) comes from Server.
        // it means that the message is seen.
        case ChatMessageVOTypes.SEEN.intValue():
            responseOfOnSeenMessage(withMessage: message)
            break
            
            // a message of type 6 (PING) comes from Server.
        // it means that a ping message comes.
        case ChatMessageVOTypes.PING.intValue():
            log.verbose("Message of type 'PING' recieved", context: "Chat")
            break
            
            // a message of type 7 (BLOCK) comes from Server.
        // it means that a user has blocked.
        case ChatMessageVOTypes.BLOCK.intValue():
            responseOfBlock(withMessage: message)
            break
            
            // a message of type 8 (UNBLOCK) comes from Server.
        // it means that a user has unblocked.
        case ChatMessageVOTypes.UNBLOCK.intValue():
            responseOfUnblockContact(withMessage: message)
            break
            
            // a message of type 9 (LEAVE_THREAD) comes from Server.
        // it means that a you has leaved the thread.
        case ChatMessageVOTypes.LEAVE_THREAD.intValue():
            responseOfLeaveThread(withMessage: message)
            break
            
        // a message of type 10 (RENAME) comes from Server.
        case ChatMessageVOTypes.RENAME.intValue():
            //
            break
            
            // a message of type 11 (ADD_PARTICIPANT) comes from Server.
        // it means some participants added to the thread.
        case ChatMessageVOTypes.ADD_PARTICIPANT.intValue():
            responseOfAddParticipant(withMessage: message)
            break
            
        // a message of type 12 (GET_STATUS) comes from Server.
        case ChatMessageVOTypes.GET_STATUS.intValue():
            //
            break
            
        // a message of type 13 (GET_CONTACTS) comes from Server.
        case ChatMessageVOTypes.GET_CONTACTS.intValue():
            responseOfGetContacts(withMessage: message)
            break
            
        // a message of type 14 (GET_THREADS) comes from Server.
        case ChatMessageVOTypes.GET_THREADS.intValue():
            responseOfGetThreads(withMessage: message)
            break
            
        // a message of type 15 (GET_HISTORY) comes from Server.
        case ChatMessageVOTypes.GET_HISTORY.intValue():
            responseOfGetHistory(withMessage: message)
            break
            
        // a message of type 16 (CHANGE_TYPE) comes from Server.
        case ChatMessageVOTypes.CHANGE_TYPE.intValue():
            break
            
        // a message of type 17 (REMOVED_FROM_THREAD) comes from Server.
        case ChatMessageVOTypes.REMOVED_FROM_THREAD.intValue():
            userRemovedFromThread(id: message.subjectId)
            break
            
        // a message of type 18 (REMOVE_PARTICIPANT) comes from Server.
        case ChatMessageVOTypes.REMOVE_PARTICIPANT.intValue():
            responseOfRemoveParticipant(withMessage: message)
            break
            
        // a message of type 19 (MUTE_THREAD) comes from Server.
        case ChatMessageVOTypes.MUTE_THREAD.intValue():
            responseOfMuteThread(withMessage: message)
            break
            
        // a message of type 20 (UNMUTE_THREAD) comes from Server.
        case ChatMessageVOTypes.UNMUTE_THREAD.intValue():
            responseOfUnmuteThread(withMessage: message)
            break
            
        // a message of type 21 (UPDATE_THREAD_INFO) comes from Server.
        case ChatMessageVOTypes.UPDATE_THREAD_INFO.intValue():
            responseOfUpdateThreadInfo(withMessage: message)
            break
            
        // a message of type 22 (FORWARD_MESSAGE) comes from Server.
        case ChatMessageVOTypes.FORWARD_MESSAGE.intValue():
            log.verbose("Message of type 'FORWARD_MESSAGE' recieved", context: "Chat")
            chatMessageHandler(threadId: message.subjectId ?? 0, messageContent: messageContentAsJSON)
            break
            
        // a message of type 23 (USER_INFO) comes from Server.
        case ChatMessageVOTypes.USER_INFO.intValue():
            responseOfUserInfo(withMessage: message)
            break
            
        // a message of type 24 (USER_STATUS) comes from Server.
        case ChatMessageVOTypes.USER_STATUS.intValue():
            break
            
        // a message of type 25 (GET_BLOCKED) comes from Server.
        case ChatMessageVOTypes.GET_BLOCKED.intValue():
            responseOfGetBlockedList(withMessage: message)
            break
            
        // a message of type 26 (RELATION_INFO) comes from Server.
        case ChatMessageVOTypes.RELATION_INFO.intValue():
            break
            
        // a message of type 27 (THREAD_PARTICIPANTS) comes from Server.
        case ChatMessageVOTypes.THREAD_PARTICIPANTS.intValue():
            responseOfThreadParticipants(withMessage: message)
            break
            
        // a message of type 28 (EDIT_MESSAGE) comes from Server.
        case ChatMessageVOTypes.EDIT_MESSAGE.intValue():
            responseOfEditMessage(withMessage: message)
            break
            
        // a message of type 29 (DELETE_MESSAGE) comes from Server.
        case ChatMessageVOTypes.DELETE_MESSAGE.intValue():
            responseOfDeleteMessage(withMessage: message)
            break
            
        // a message of type 30 (THREAD_INFO_UPDATED) comes from Server.
        case ChatMessageVOTypes.THREAD_INFO_UPDATED.intValue():
            threadInfoUpdated(withMessage: message)
            break
            
        // a message of type 31 (LAST_SEEN_UPDATED) comes from Server.
        case ChatMessageVOTypes.LAST_SEEN_UPDATED.intValue():
            log.verbose("Message of type 'LAST_SEEN_UPDATED' recieved", context: "Chat")
//            delegate?.threadEvents(type: ThreadEventTypes.THREAD_UNREAD_COUNT_UPDATED, threadId: message.subjectId, thread: nil, messageId: message.messageId, senderId: message.participantId)
//            delegate?.threadEvents(type: ThreadEventTypes.THREAD_LAST_ACTIVITY_TIME, threadId: message.subjectId, thread: nil, messageId: nil, senderId: nil)
//            delegate?.threadEvents(type: ThreadEventTypes.lastSeenUpdate, result: messageContent)
            let tUnreadCountUpdateEM = ThreadEventModel(type:           ThreadEventTypes.THREAD_UNREAD_COUNT_UPDATED,
                                                        participants:   nil,
                                                        threads:        nil,
                                                        threadId:       message.subjectId,
                                                        senderId:       message.participantId,
                                                        unreadCount:    message.content?.convertToJSON()["unreadCount"].int,
                                                        pinMessage:     nil)
            delegate?.threadEvents(model: tUnreadCountUpdateEM)
            let tActivityTimeEM = ThreadEventModel(type:            ThreadEventTypes.THREAD_LAST_ACTIVITY_TIME,
                                                   participants:    nil,
                                                   threads:         nil,
                                                   threadId:        message.subjectId,
                                                   senderId:        nil,
                                                   unreadCount:     message.content?.convertToJSON()["unreadCount"].int,
                                                   pinMessage:      nil)
            delegate?.threadEvents(model: tActivityTimeEM)
            
            if let count = message.content?.convertToJSON()["unreadCount"].int, let threadId = message.subjectId {
                Chat.cacheDB.updateUnreadCountOnCMConversation(withThreadId: threadId, unreadCount: count, addCount: nil)
            }
            
            
            // this functionality has beed deprecated
            /*
             let paramsToSend: JSON = ["threadIds": messageContent["conversationId"].intValue]
             getThreads(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
             let myResponseModel: GetThreadsModel = myResponse as! GetThreadsModel
             let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
             let threads = myResponseJSON["result"]["threads"].arrayValue
             
             let result: JSON = ["thread": threads,
             "messageId": messageContent["messageId"].intValue,
             "senderId": messageContent["participantId"].intValue]
             self.delegate?.threadEvents(type: "THREAD_UNREAD_COUNT_UPDATED", result: result)
             
             let result2: JSON = ["thread": threads]
             self.delegate?.threadEvents(type: "THREAD_LAST_ACTIVITY_TIME", result: result2)
             }
             */
            
            break
            
        // a message of type 32 (GET_MESSAGE_DELEVERY_PARTICIPANTS) comes from Server.
        case ChatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.intValue():
            responseOfMessageDeliveryList(withMessage: message)
            break
            
        // a message of type 33 (GET_MESSAGE_SEEN_PARTICIPANTS) comes from Server.
        case ChatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.intValue():
            responseOfMessageSeenList(withMessage: message)
            break
            
        // a message of type 34 (IS_NAME_AVAILABLE) comes from Server.
        case ChatMessageVOTypes.IS_NAME_AVAILABLE.intValue():
            responseOfIsPublicThreadNameAvailable(withMessage: message)
            break
            
        // a message of type 39 (JOIN_THREAD) comes from Server.
        case ChatMessageVOTypes.JOIN_THREAD.intValue():
            responseOfJoinPublicThread(withMessage: message)
            break
            
        // a message of type 40 (BOT_MESSAGE) comes from Server.
        case ChatMessageVOTypes.BOT_MESSAGE.intValue():
            log.verbose("Message of type 'BOT_MESSAGE' recieved", context: "Chat")
            let botEventModel = BotEventModel(type:     BotEventTypes.BOT_MESSAGE,
                                              message:  message.content)
            delegate?.botEvents(model: botEventModel)
            break
            
        // a message of type 41 (SPAM_PV_THREAD) comes from Server.
        case ChatMessageVOTypes.SPAM_PV_THREAD.intValue():
//            responseOfSpamPvThread(withMessage: message)
            break
            
        // a message of type 42 (SET_RULE_TO_USER) comes from Server.
        case ChatMessageVOTypes.SET_RULE_TO_USER.intValue():
            responseOfSetRoleToUser(withMessage: message)
            break
            
        // a message of type 43 (SET_RULE_TO_USER) comes from Server.
        case ChatMessageVOTypes.REMOVE_ROLE_FROM_USER.intValue():
            responseOfRemoveRoleFromUser(withMessage: message)
            break
            
        // a message of type 44 (CLEAR_HISTORY) comes from Server.
        case ChatMessageVOTypes.CLEAR_HISTORY.intValue():
            responseOfClearHistory(withMessage: message)
            break
            
        // a message of type 46 (SYSTEM_MESSAGE) comes from Server
        case ChatMessageVOTypes.SYSTEM_MESSAGE.intValue():
            log.verbose("Message of type 'SYSTEM_MESSAGE' revieved", context: "Chat")
            
            let systemEventModel = SystemEventModel(type:       SystemEventTypes.IS_TYPING,
                                                    time:       nil,
                                                    threadId:   message.subjectId,
                                                    user:       message.content)
            delegate?.systemEvents(model: systemEventModel)
            return
            
        // a message of type 47 (GET_NOT_SEEN_DURATION) comes from Server.
        case ChatMessageVOTypes.GET_NOT_SEEN_DURATION.intValue():
            responseOfGetContactNotSeenDuration(withMessage: message)
            break
            
        // a message of type 48 (PIN_THREAD) comes from Server.
        case ChatMessageVOTypes.PIN_THREAD.intValue():
            responseOfPinThread(withMessage: message)
            break
            
        // a message of type 49 (UNPIN_THREAD) comes from Server.
        case ChatMessageVOTypes.UNPIN_THREAD.intValue():
            responseOfUnpinThread(withMessage: message)
            break
            
        // a message of type 50 (PIN_MESSAGE) comes from Server.
        case ChatMessageVOTypes.PIN_MESSAGE.intValue():
            responseOfPinMessage(withMessage: message)
            break
            
        // a message of type 51 (UNPIN_MESSAGE) comes from Server.
        case ChatMessageVOTypes.UNPIN_MESSAGE.intValue():
            responseOfUnpinMessage(withMessage: message)
            break
            
        // a message of type 52 (SET_PROFILE) comes from Server.
        case ChatMessageVOTypes.SET_PROFILE.intValue():
            responseOfUpdateChatProfile(withMessage: message)
            break
        
        // a message of type 54 (GET_CURRENT_USER_ROLES) comes from Server
        case ChatMessageVOTypes.GET_CURRENT_USER_ROLES.intValue():
            responseOfGetCurrentUserRoles(withMessage: message)
        
        // a message of type 60 (CONTACTS_LAST_SEEN) comes from Server.
        case ChatMessageVOTypes.CONTACTS_LAST_SEEN.intValue():
            sendContactsLastSeenDurationUpdate(withMessage: message)
            break
            
        // a message of type 61 (ALL_UNREAD_MESSAGE_COUNT) comes from Server.
        case ChatMessageVOTypes.ALL_UNREAD_MESSAGE_COUNT.intValue():
            responseOfAllUnreadMessageCount(withMessage: message)
            break
            
        // a message of type 62 (CREATE_BOT) comes from Server.
        case ChatMessageVOTypes.CREATE_BOT.intValue():
            responseOfCreateBot(withMessage: message)
            break
            
        // a message of type 63 (DEFINE_BOT_COMMAND) comes from Server.
        case ChatMessageVOTypes.DEFINE_BOT_COMMAND.intValue():
            responseOfAddBotCommand(withMessage: message)
            break
            
        // a message of type 64 (START_BOT) comes from Server.
        case ChatMessageVOTypes.START_BOT.intValue():
            responseOfStartBot(withMessage: message)
            break
            
        // a message of type 65 (STOP_BOT) comes from Server.
        case ChatMessageVOTypes.STOP_BOT.intValue():
            responseOfStopBot(withMessage: message)
            break
            
        // a message of type 90 (CONTACT_SYNCED) comes from Server.
        case ChatMessageVOTypes.CONTACT_SYNCED.intValue():
            responseOfUserContactSynced(withMessage: message)
            break
        
        // a message of type 100 (LOGOUT) comes from Server.
        case ChatMessageVOTypes.LOGOUT.intValue():
            break
        
        // a message of type 101 (STATUS_PING) comes from Server.
        case ChatMessageVOTypes.STATUS_PING.intValue():
            responseOfStatusPing(withMessage: message)
            break
            
        // a message of type 102 (CLOSE_THREAD) comes from Server.
        case ChatMessageVOTypes.CLOSE_THREAD.intValue():
            responseOfCloseThread(withMessage: message)
            break
            
        // a message of type 999 (ERROR) comes from Server.
        case ChatMessageVOTypes.ERROR.intValue():
            chatErrorHandler(withMessage: message, messageContentAsJSON: messageContentAsJSON)
            break
            
        default:
            log.verbose("This type of message is not defined yet!!!\n incomes = \(message.returnToJSON())", context: "Chat")
            break
        }
    }
    
    private func chatErrorHandler(withMessage message: ChatMessage, messageContentAsJSON: JSON) {
        log.verbose("Message of type 'ERROR' recieved", context: "Chat")
        
        // send log to Sentry 4.3.1
        if captureSentryLogs {
            let event = Event(level: SentrySeverity.error)
            event.message = "Message of type 'ERROR' recieved: \n \(message.returnToJSON())"
            Client.shared?.send(event: event, completion: { _ in })
        }
        
        // send log to Sentry 5.0.5
//        let event = Event(level: SentryLevel.error)
//        event.message = "Message of type 'ERROR' recieved"
//        SentrySDK.capture(event: event)
        
//        let b = Breadcrumb(level: SentryLevel.error, category: "iOS")
//        b.message = ""
        
//        SentrySDK.capture(event: event) { (scope) in
//        }
//        SentrySDK.addBreadcrumb(crumb: <#T##Breadcrumb#>)
//        SentrySDK.capture(message: <#T##String#>)
        
        if Chat.map[message.uniqueId] != nil {
            let returnData = CreateReturnData(hasError:         true,
                                              errorMessage:     message.message,
                                              errorCode:        message.code,
                                              result:           messageContentAsJSON,
                                              resultAsArray:    nil,
                                              resultAsString:   nil,
                                              contentCount:     0,
                                              subjectId:        message.subjectId)
            
            let callback: CallbackProtocol = Chat.map[message.uniqueId]!
            callback.onResultCallback(uID:      message.uniqueId,
                                      response: returnData,
                                      success:  { (successJSON) in
                self.spamPvThreadCallbackToUser?(successJSON)
            }) { _ in }
            Chat.map.removeValue(forKey: message.uniqueId)
            
            // ToDo: what to do when authenticationError comes
//            if (messageContentAsJSON["code"].intValue == 21) {
//                isChatReady = false
//                asyncClient?.disposeAsyncObject()
//            }
            delegate?.chatError(errorCode:      message.code    ?? messageContentAsJSON["code"].int         ?? 0,
                                errorMessage:   message.message ?? messageContentAsJSON["message"].string   ?? "",
                                errorResult:    messageContentAsJSON)
        }
        
    }
    
    
    func chatMessageHandler(threadId: Int, messageContent: JSON) {
        let message = Message(threadId: threadId, pushMessageVO: messageContent)
        
        if let messageOwner = message.participant?.id {
            if messageOwner != userInfo?.id {
                Chat.cacheDB.updateUnreadCountOnCMConversation(withThreadId: threadId, unreadCount: nil, addCount: 1)
                let deliveryModel = DeliverSeenRequestModel(messageId:  message.id ?? 0,
                                                            ownerId:    messageOwner,
                                                            typeCode:   nil)
//                seen(inputModel: deliveryModel)
                deliver(inputModel: deliveryModel)
            }
        }
        
        if enableCache {
            // save data comes from server to the Cache
            let theMessage = Message(threadId: threadId, pushMessageVO: messageContent)
            Chat.cacheDB.saveMessageObjects(messages: [theMessage], getHistoryParams: nil)
        }
        
        let messageEventModel = MessageEventModel(type:     MessageEventTypes.MESSAGE_NEW,
                                                  message:  message,
                                                  threadId: threadId,
                                                  messageId: nil,
                                                  senderId: nil,
                                                  pinned:   messageContent["pinned"].bool)
        delegate?.messageEvents(model: messageEventModel)
        let tLastActivityEM = ThreadEventModel(type:            ThreadEventTypes.THREAD_LAST_ACTIVITY_TIME,
                                               participants:    nil,
                                               threads:         nil,
                                               threadId:        threadId,
                                               senderId:        nil,
                                               unreadCount:     messageContent["unreadCount"].int,
                                               pinMessage:      nil)
        delegate?.threadEvents(model: tLastActivityEM)
        let tUnreadCountEM = ThreadEventModel(type:         ThreadEventTypes.THREAD_UNREAD_COUNT_UPDATED,
                                              participants: nil,
                                              threads:      nil,
                                              threadId:     threadId,
                                              senderId:     nil,
                                              unreadCount:  messageContent["unreadCount"].int ?? message.conversation?.unreadCount,
                                              pinMessage:   nil)
        delegate?.threadEvents(model: tUnreadCountEM)
        
    }
    
    
    func userRemovedFromThread(id: Int?) {
        if let threadId = id {
            let tRemoveFromThreadEM = ThreadEventModel(type:            ThreadEventTypes.THREAD_REMOVED_FROM,
                                                       participants:    nil,
                                                       threads:         nil,
                                                       threadId:        threadId,
                                                       senderId:        nil,
                                                       unreadCount:     nil,
                                                       pinMessage:      nil)
            delegate?.threadEvents(model: tRemoveFromThreadEM)
            
            if enableCache {
                Chat.cacheDB.deleteThreads(withThreadIds: [threadId])
            }
        }
    }
    
    
    func threadInfoUpdated(withMessage message: ChatMessage) {
        log.verbose("Message of type 'THREAD_INFO_UPDATED' recieved", context: "Chat")
        
        let conversation = Conversation(messageContent: message.content?.convertToJSON() ?? [:])
        let tInfoUpdatedEM = ThreadEventModel(type:         ThreadEventTypes.THREAD_INFO_UPDATED,
                                              participants: nil,
                                              threads:      [conversation],
                                              threadId:     message.subjectId,
                                              senderId:     nil,
                                              unreadCount:  message.content?.convertToJSON()["unreadCount"].int,
                                              pinMessage:   nil)
        delegate?.threadEvents(model: tInfoUpdatedEM)
        
        if let count = message.content?.convertToJSON()["unreadCount"].int, let threadId = message.subjectId {
            Chat.cacheDB.updateUnreadCountOnCMConversation(withThreadId: threadId, unreadCount: count, addCount: nil)
        }
    }
    
    
    func sendContactsLastSeenDurationUpdate(withMessage message: ChatMessage) {
        if let object = message.content?.convertToJSON() {
            var users = [UserLastSeenDuration]()
            for item in object {
                users.append(UserLastSeenDuration(userId: Int(item.0)!, time: item.1.intValue))
            }
            let eventModel = ContactEventModel(type:                        ContactEventTypes.CONTACTS_LAST_SEEN,
                                               contacts:                    nil,
                                               contactsLastSeenDuration:    users)
            delegate?.contactEvents(model: eventModel)
        }
    }
    
    
    func responseOfUserContactSynced(withMessage message: ChatMessage) {
        Chat.cacheDB.updateUserContactSynced()
    }
    
}



