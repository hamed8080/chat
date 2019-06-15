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

// MARK: -
// MARK: - Private Methods:

extension Chat {
    
    
    func getDeviceIdWithToken(completion: @escaping (String) -> ()) {
        let url = ssoHost + SERVICES_PATH.SSO_DEVICES.rawValue
        let method: HTTPMethod = .get
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: nil, dataToSend: nil, requestUniqueId: nil, isImage: nil, isFile: nil, completion: { (myResponse) in
            let responseStr: String = myResponse as! String
            if let dataFromMsgString = responseStr.data(using: .utf8, allowLossyConversion: false) {
                // get currrent user deviceIdresponseStr
                var msg: JSON
                do {
                    msg = try JSON(data: dataFromMsgString)
                } catch {
                    fatalError()
                }
                
                if let devices = msg["devices"].array {
                    for device in devices {
                        if device["current"].bool == true {
                            completion(device["uid"].stringValue)
                            break
                        }
                    }
                    if (self.deviceId == nil || (self.deviceId == "")) {
                        self.delegate?.chatError(errorCode: 6000, errorMessage: CHAT_ERRORS.err6000.rawValue, errorResult: nil)
                    }
                } else {
                    self.delegate?.chatError(errorCode: 6001, errorMessage: CHAT_ERRORS.err6001.rawValue, errorResult: nil)
                }
                
            }
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_  in }
        
        
    }
    
    
    func httpRequest(from urlStr:           String,
                     withMethod:            HTTPMethod,
                     withHeaders:           HTTPHeaders?,
                     withParameters:        Parameters?,
                     dataToSend:            Any?,
                     requestUniqueId:       String?,
                     isImage:               Bool?,
                     isFile:                Bool?,
                     completion:            @escaping callbackTypeAlias,
                     progress:              callbackTypeAliasFloat?,
                     idDownloadRequest:     Bool,
                     isMapServiceRequst:    Bool,
                     downloadReturnData:    @escaping (Data?, JSON) -> ()) {
        
        let url = URL(string: urlStr)!
        
        if (idDownloadRequest) {
            
            Alamofire.request(url, method: withMethod, parameters: withParameters, headers: withHeaders).downloadProgress(closure: { (downloadProgress) in
                let myProgressFloat: Float = Float(downloadProgress.fractionCompleted)
                progress?(myProgressFloat)
            }).responseData { (myResponse) in
                if myResponse.result.isSuccess {
                    if let downloadedData = myResponse.data {
                        if let response = myResponse.response {
                            
                            var resJSON: JSON = [:]
                            
                            let headerResponse = response.allHeaderFields
                            if let contentType = headerResponse["Content-Type"] as? String {
                                if let fileType = contentType.components(separatedBy: "/").last {
                                    resJSON["type"] = JSON(fileType)
                                }
                            }
                            if let contentDisposition = headerResponse["Content-Disposition"] as? String {
                                if let theFileName = contentDisposition.components(separatedBy: "=").last?.replacingOccurrences(of: "\"", with: "") {
                                    resJSON["name"] = JSON(theFileName)
                                }
                                // return the Data:
                                downloadReturnData(downloadedData, resJSON)
                            } else {
                                // an error accured, so return the error:
                                let returnJSON: JSON = ["hasError": true, "errorCode": 999]
                                downloadReturnData(nil, returnJSON)
                            }
                            
                        }
                    }
                } else {
                    print("Failed!")
                }
            }
            
        } else {
            
            if (withMethod == .get) {
                
                if isMapServiceRequst {
                    Alamofire.request(url, method: withMethod, parameters: withParameters, headers: withHeaders).responseJSON { (myResponse) in
                        if myResponse.result.isSuccess {
                            if let jsonValue = myResponse.result.value {
                                let jsonResponse: JSON = JSON(jsonValue)
                                completion(jsonResponse)
                            }
                        } else {
                            log.error("Response of GerRequest is Failed)", context: "Chat")
                        }
                    }
                    
                } else {
                    Alamofire.request(url, method: withMethod, parameters: withParameters, headers: withHeaders).responseString { (response) in
                        if response.result.isSuccess {
                            let stringToReturn: String = response.result.value!
                            completion(stringToReturn)
                        } else {
                            log.error("Response of GerRequest is Failed)", context: "Chat")
                        }
                    }
                }
                
            } else if (withMethod == .post) {
                
                if dataToSend == nil {
                    Alamofire.request(url, method: withMethod, parameters: withParameters, headers: withHeaders).responseJSON { (myResponse) in
                        if myResponse.result.isSuccess {
                            if let jsonValue = myResponse.result.value {
                                let jsonResponse: JSON = JSON(jsonValue)
                                completion(jsonResponse)
                            }
                        } else {
                            if let error = myResponse.error {
                                let myJson: JSON = ["hasError": true,
                                                    "errorCode": 6200,
                                                    "errorMessage": "\(CHAT_ERRORS.err6200.rawValue) \(error)",
                                    "errorEvent": error.localizedDescription]
                                completion(myJson)
                            }
                        }
                    }
                    
                } else {
                    
                    Alamofire.upload(multipartFormData: { (multipartFormData) in
                        
                        if let hasImage = isImage {
                            if (hasImage == true) {
                                multipartFormData.append(dataToSend as! Data, withName: "image")
                            }
                        }
                        
                        if let hasFile = isFile {
                            if (hasFile == true) {
                                multipartFormData.append(dataToSend as! Data, withName: "file")
                            }
                        }
                        
                        
                        if let header = withHeaders {
                            for (key, value) in header {
                                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key as String)
                            }
                        }
                        if let parameters = withParameters {
                            for (key, value) in parameters {
                                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key as String)
                            }
                        }
                    }, to: urlStr) { (myResult) in
                        switch myResult {
                        case .success(let upload, _, _):
                            self.uploadRequest.append((upload: upload, uniqueId: requestUniqueId!))
                            upload.responseJSON(completionHandler: { (response) in
                                if let jsonValue = response.result.value {
                                    let jsonResponse: JSON = JSON(jsonValue)
                                    completion(jsonResponse)
                                }
                            })
                            upload.uploadProgress(closure: { (myProgress) in
                                let myProgressFloat: Float = Float(myProgress.fractionCompleted)
                                progress?(myProgressFloat)
                            })
                            upload.responseJSON { response in
                                debugPrint(response)
                                for (index, item) in self.uploadRequest.enumerated() {
                                    if item.uniqueId == requestUniqueId {
                                        self.uploadRequest.remove(at: index)
                                    }
                                }
                                
                            }
                        case .failure(let error):
                            completion(error)
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    func sendMessageWithCallback(params: JSON, callback: CallbackProtocol?, sentCallback: CallbackProtocolWith3Calls?, deliverCallback: CallbackProtocolWith3Calls?, seenCallback: CallbackProtocolWith3Calls?, uniuqueIdCallback: callbackTypeAliasString?) {
        log.verbose("params (to send): \n \(params)", context: "Chat")
        
        /*
         * + ChatMessage        {object}
         *    - token           {string}
         *    - tokenIssuer     {string}
         *    - type            {int}
         *    - subjectId       {long}
         *    - uniqueId        {string}
         *    - content         {string}
         *    - time            {long}
         *    - medadata        {string}
         *    - systemMedadata  {string}
         *    - repliedTo       {long}
         */
        //        var returnData: JSON = ["uniqueId": "", "threadId": 0, "participant": userInfo as Any, "content": params["content"]]
        
        var messageVO: JSON = ["type": params["chatMessageVOType"].intValue,
                               "token": token,
                               "tokenIssuer": 1]
        var threadId: Int = 0
        if let theSubjectId = params["subjectId"].int {
            threadId = theSubjectId
            messageVO["threadId"] = JSON(theSubjectId)
            messageVO["subjectId"] = JSON(theSubjectId)
        }
        
        if let repliedTo = params["repliedTo"].int {
            messageVO["repliedTo"] = JSON(repliedTo)
        }
        
        if let content = params["content"].string {
            messageVO["content"] = JSON(content)
        } else {
            let content = "\(params["content"])"
            messageVO["content"] = JSON(content)
        }
        
        if let metaData = params["metaData"].string {
            messageVO["metaData"] = JSON(metaData)
        }
        
        if let systemMetadata = params["systemMetadata"].string {
            messageVO["systemMetadata"] = JSON(systemMetadata)
        }
        
        if let typeCode = params["typeCode"].string {
            messageVO["typeCode"] = JSON(typeCode)
        } else {
            //            messageVO["typeCode"] = JSON(generalTypeCode)
        }
        
        var uniqueId: String = ""
        if let uID = params["uniqueId"].string {
            messageVO["uniqueId"] = JSON(uID)
            //            returnData["uniqueId"] = JSON(uID)
            uniqueId = uID
        } else if params["chatMessageVOType"].intValue != chatMessageVOTypes.PING.rawValue {
            let uID = generateUUID()
            messageVO["uniqueId"] = JSON(uID)
            //            returnData["uniqueId"] = JSON(uID)
            uniqueId = uID
        }
        uniuqueIdCallback?(uniqueId)
        
        log.verbose("MessageVO params (to send): \n \(messageVO)", context: "Chat")
        
        if (callback != nil) {
            Chat.map[uniqueId] = callback
        }
        
        if (sentCallback != nil) {
            Chat.mapOnSent[uniqueId] = sentCallback
        }
        
        if (deliverCallback != nil) {
            let uniqueIdDic: [String: CallbackProtocolWith3Calls] = [uniqueId: deliverCallback!]
            if Chat.mapOnDeliver["\(threadId)"] != nil {
                Chat.mapOnDeliver["\(threadId)"]!.append(uniqueIdDic)
            } else {
                Chat.mapOnDeliver["\(threadId)"] = [uniqueIdDic]
            }
        }
        
        if (seenCallback != nil) {
            let uniqueIdDic: [String: CallbackProtocolWith3Calls] = [uniqueId: deliverCallback!]
            if Chat.mapOnSeen["\(threadId)"] != nil {
                Chat.mapOnSeen["\(threadId)"]!.append(uniqueIdDic)
            } else {
                Chat.mapOnSeen["\(threadId)"] = [uniqueIdDic]
            }
        }
        
        //        if (sentCallback != nil) {
        //
        //            Chat.mapOnSent[uniqueId] = sentCallback
        //            let uniqueIdDic: [String: CallbackProtocolWith3Calls] = [uniqueId: deliverCallback!]
        //
        //            if Chat.mapOnDeliver["\(threadId)"] != nil {
        //                Chat.mapOnDeliver["\(threadId)"]!.append(uniqueIdDic)
        //            } else {
        //                Chat.mapOnDeliver["\(threadId)"] = [uniqueIdDic]
        //            }
        //
        //            if Chat.mapOnSeen["\(threadId)"] != nil {
        //                Chat.mapOnSeen["\(threadId)"]!.append(uniqueIdDic)
        //            } else {
        //                Chat.mapOnSeen["\(threadId)"] = [uniqueIdDic]
        //            }
        //
        //        } else {
        //            Chat.map[uniqueId] = callback
        //        }
        
        log.verbose("map json: \n \(Chat.map)", context: "Chat")
        log.verbose("map onSent json: \n \(Chat.mapOnSent)", context: "Chat")
        log.verbose("map onDeliver json: \n \(Chat.mapOnDeliver)", context: "Chat")
        log.verbose("map onSeen json: \n \(Chat.mapOnSeen)", context: "Chat")
        
        
        var type: Int = 3
        if let theType = params["pushMsgType"].int {
            type = theType
        }
        var content: JSON = [:]
        let messageVOStr = "\(messageVO)"
        let str = String(messageVOStr.filter { !"\n\t\r".contains($0) })
        content["content"] = JSON("\(str)")
        content["peerName"] = JSON(serverName)
        content["priority"] = JSON(msgPriority)
        content["ttl"] = JSON(msgTTL)
        let contentStr = "\(content)"
        
        let str2 = String(contentStr.filter { !"\n\t\r".contains($0) })
        log.verbose("AsyncMessageContent of type JSON (to send to socket): \n \(str2)", context: "Chat")
        
        asyncClient?.pushSendData(type: type, content: str2)
        runSendMessageTimer()
    }
    
    
    /* this method is deprecated because af using a class inside Async
    /*
     it's all about this 3 characters: 'space' , '\n', '\t'
     this function will put some freak characters instead of these 3 characters (inside the Message text content)
     because later on, the Async will eliminate from all these kind of characters to reduce size of the message that goes through socket,
     on there, we will replace them with the original one;
     so now we don't miss any of these 3 characters on the Test Message, but also can eliminate all extra characters...
     */
    func makeCustomTextToSend(textMessage: String) -> String {
        var returnStr = ""
        for c in textMessage {
            if (c == " ") {
                returnStr.append("Ⓢ")
            } else if (c == "\n") {
                returnStr.append("Ⓝ")
            } else if (c == "\t") {
                returnStr.append("Ⓣ")
            } else {
                returnStr.append(c)
            }
        }
        return returnStr
    }
    */
    
    
    func runSendMessageTimer() {
        self.lastSentMessageTimeoutId?.suspend()
        DispatchQueue.global().async {
            self.lastSentMessageTime = Date()
            self.lastSentMessageTimeoutId = RepeatingTimer(timeInterval: TimeInterval(self.chatPingMessageInterval))
            self.lastSentMessageTimeoutId?.eventHandler = {
                if let lastSendMessageTimeBanged = self.lastSentMessageTime {
                    let elapsed = Date().timeIntervalSince(lastSendMessageTimeBanged)
                    let elapsedInt = Int(elapsed)
                    if (elapsedInt >= self.chatPingMessageInterval) && (self.chatState == true) {
                        DispatchQueue.main.async {
                            self.ping()
                        }
                        self.lastSentMessageTimeoutId?.suspend()
                    }
                }
            }
            self.lastSentMessageTimeoutId?.resume()
        }
    }
    
    
    func ping() {
        if (chatState == true && peerId != nil && peerId != 0) {
            
            log.verbose("Try to send Ping", context: "Chat")
            
            let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.PING.rawValue, "pushMsgType": 4]
            _ = sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: nil, deliverCallback: nil, seenCallback: nil, uniuqueIdCallback: nil)
        } else if (lastSentMessageTimeoutId != nil) {
            lastSentMessageTimeoutId?.suspend()
        }
    }
    
    
    
    func pushMessageHandler(params: JSON) {
        
        log.verbose("receive message: \n \(params)", context: "Chat")
        
        /**
         * + Message Received From Async      {object}
         *    - id                            {long}
         *    - senderMessageId               {long}
         *    - senderName                    {string}
         *    - senderId                      {long}
         *    - type                          {int}
         *    - content                       {string}
         */
        
        lastReceivedMessageTime = Date()
        
        let content = params["content"].stringValue
        
        // convert my parameters data from string to JSON
        let msgJSON: JSON = formatDataFromStringToJSON(stringCont: content).convertStringContentToJSON()
        receivedMessageHandler(params: msgJSON)
    }
    
    
    func receivedMessageHandler(params: JSON) {
        //        print("\n\n &&&&&&&&&& \n recievedMessage: \n \(params) \n &&&&&&&&&& \n\n")
        log.debug("content of received message: \n \(params)", context: "Chat")
        
        /*
         * + Chat Message Received Content  {object}
         *    - threadId                    {long}
         *    - type                        {int}
         *    - contentCount                {int}
         *    - uniqueId                    {string}
         *    - content                     {string}
         */
        
        let type = params["type"].intValue
        let uniqueId = params["uniqueId"].stringValue
        var threadId = 0
        if let theThreadId = params["subjectId"].int {
            threadId = theThreadId
        }
        var contentCount = 0
        if let theContentCount = params["contentCount"].int {
            contentCount = theContentCount
        }
        var messageContent: JSON = [:]
        var messageContentAsString = ""
        if let msgCont = params["content"].string {
            messageContentAsString = msgCont
            messageContent = formatDataFromStringToJSON(stringCont: msgCont).convertStringContentToJSON()
        }
        
        switch type {
            
        // a message of type 1 (CREATE_THREAD) comes from Server.
        case chatMessageVOTypes.CREATE_THREAD.rawValue:
            log.verbose("Message of type 'CREATE_THREAD' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                //                let threadData = Conversation(messageContent: messageContent).formatToJSON()
                //                delegate?.threadEvents(type: ThreadEventTypes.new, result: threadData)
                //                chatDelegateCreateThread(createThread: threadData)
                
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.createThreadCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
            // a message of type 2 (MESSAGE) comes from Server.
        // this means that a message comes.
        case chatMessageVOTypes.MESSAGE.rawValue:
            log.verbose("Message of type 'MESSAGE' recieved", context: "Chat")
            chatMessageHandler(threadId: threadId, messageContent: messageContent)
            break
            
            // a message of type 3 (SENT) comes from Server.
        // it means that the message is send.
        case chatMessageVOTypes.SENT.rawValue:
            log.verbose("Message of type 'SENT' recieved", context: "Chat")
            if Chat.mapOnSent[uniqueId] != nil {
                let callback: CallbackProtocolWith3Calls = Chat.mapOnSent[uniqueId]!
                messageContent = ["messageId": params["content"].stringValue]
                callback.onSent(uID: uniqueId, response: params) { (successJSON) in
                    self.sendCallbackToUserOnSent?(successJSON)
                }
                Chat.mapOnSent.removeValue(forKey: uniqueId)
            }
            break
            
            // a message of type 4 (DELIVERY) comes from Server.
        // it means that the message is delivered.
        case chatMessageVOTypes.DELIVERY.rawValue:
            log.verbose("Message of type 'DELIVERY' recieved", context: "Chat")
            
            // this functionality has beed deprecated
            /*
             let paramsToSend: JSON = ["offset": 0,
             "threadId": threadId,
             "id": messageContent["messageId"].int ?? NSNull()]
             getHistory(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
             let myResponseModel: GetHistoryModel = myResponse as! GetHistoryModel
             let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
             if !(myResponseJSON["hasError"].boolValue) {
             let history = myResponseJSON["history"].arrayObject
             let result: JSON = ["threadId": threadId,
             "senderId": messageContent["participantId"].int ?? NSNull(),
             "message": history?.first ?? NSNull()]
             self.delegate?.messageEvents(type: "MESSAGE_DELIVERY", result: result)
             }
             }
             */
            
            var findItAt: Int?
            let threadIdObject = Chat.mapOnDeliver["\(threadId)"]
            if let threadIdObj = threadIdObject {
                let threadIdObjCount = threadIdObj.count
                if (threadIdObjCount > 0) {
                    for i in 1...threadIdObjCount {
                        let index = i - 1
                        let uniqueIdObj: [String: CallbackProtocolWith3Calls] = threadIdObj[index]
                        if let callback = uniqueIdObj[uniqueId] {
                            findItAt = i
                            callback.onDeliver(uID: uniqueId, response: messageContent) { (successJSON) in
                                self.sendCallbackToUserOnDeliver?(successJSON)
                            }
                        }
                    }
                }
            } else {
                /*
                 in situation that Create Thread with send Message, this part will execute,
                 because at the beginnig of creating the thread, we don't have the ThreadID
                 that we are creating,
                 so all messages that sends by creating a thread simultanously, exeute from here:
                 */
                let threadIdObject = Chat.mapOnDeliver["\(0)"]
                if let threadIdObj = threadIdObject {
                    for (index, item) in threadIdObj.enumerated() {
                        if let callback = item[uniqueId] {
                            callback.onDeliver(uID: uniqueId, response: messageContent) { (successJSON) in
                                self.sendCallbackToUserOnDeliver?(successJSON)
                            }
                            Chat.mapOnDeliver["\(0)"]?.remove(at: index)
                            break
                        }
                    }
                }
            }
            
            if let itemAt = findItAt {
                // unique ids that i have to send them that they delivery comes
                var uniqueIdsWithDelivery: [String] = []
                
                // find objects form first to index that delivery comes
                for i in 1...itemAt {
                    if let threadIdObj = threadIdObject {
                        let index = i - 1
                        let uniqueIdObj = threadIdObj[index]
                        for key in uniqueIdObj.keys {
                            uniqueIdsWithDelivery.append(key)
                        }
                    }
                }
                
                // remove items from array and update array
                for i in 0...(itemAt - 1) {
                    let index = i
                    Chat.mapOnDeliver["\(threadId)"]?.remove(at: index)
                }
                
            }
            break
            
            // a message of type 5 (SEEN) comes from Server.
        // it means that the message is seen.
        case chatMessageVOTypes.SEEN.rawValue:
            log.verbose("Message of type 'SEEN' recieved", context: "Chat")
            // this functionality has beed deprecated
            /*
             let paramsToSend: JSON = ["offset": 0,
             "threadId": threadId,
             "id": messageContent["messageId"].int ?? NSNull()]
             getHistory(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
             let myResponseModel: GetHistoryModel = myResponse as! GetHistoryModel
             let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
             if !(myResponseJSON["hasError"].boolValue) {
             let history = myResponseJSON["history"].arrayObject
             let result: JSON = ["threadId": threadId,
             "senderId": messageContent["participantId"].int ?? NSNull(),
             "message": history?.first ?? NSNull()]
             self.delegate?.messageEvents(type: "MESSAGE_SEEN", result: result)
             }
             }
             */
            
            var findItAt: Int?
            let threadIdObject = Chat.mapOnSeen["\(threadId)"]
            if let threadIdObj = threadIdObject {
                let threadIdObjCount = threadIdObj.count
                if (threadIdObjCount > 0) {
                    for i in 1...threadIdObjCount {
                        let index = i - 1
                        let uniqueIdObj: [String: CallbackProtocolWith3Calls] = threadIdObj[index]
                        if let callback = uniqueIdObj[uniqueId] {
                            findItAt = i
                            callback.onSeen(uID: uniqueId, response: messageContent) { (successJSON) in
                                self.sendCallbackToUserOnSeen?(successJSON)
                            }
                        }
                    }
                }
            } else {
                /*
                 in situation that Create Thread with send Message, this part will execute,
                 because at the beginnig of creating the thread, we don't have the ThreadID
                 that we are creating,
                 so all messages that sends by creating a thread simultanously, exeute from here:
                 */
                let threadIdObject = Chat.mapOnSeen["\(0)"]
                if let threadIdObj = threadIdObject {
                    for (index, item) in threadIdObj.enumerated() {
                        if let callback = item[uniqueId] {
                            callback.onSeen(uID: uniqueId, response: messageContent) { (successJSON) in
                                self.sendCallbackToUserOnSeen?(successJSON)
                            }
                            Chat.mapOnSeen["\(0)"]?.remove(at: index)
                            break
                        }
                    }
                }
            }
            
            if let itemAt = findItAt {
                // unique ids that i have to send them that they delivery comes
                var uniqueIdsWithDelivery: [String] = []
                
                // find objects form first to index that delivery comes
                for i in 1...itemAt {
                    if let threadIdObj = threadIdObject {
                        let index = i - 1
                        let uniqueIdObj = threadIdObj[index]
                        for key in uniqueIdObj.keys {
                            uniqueIdsWithDelivery.append(key)
                        }
                    }
                }
                
                // remove items from array and update array
                for i in 1...itemAt {
                    let index = i - 1
                    Chat.mapOnSeen["\(threadId)"]?.remove(at: index)
                }
            }
            break
            
            // a message of type 6 (PING) comes from Server.
        // it means that a ping message comes.
        case chatMessageVOTypes.PING.rawValue:
            log.verbose("Message of type 'PING' recieved", context: "Chat")
            break
            
            // a message of type 7 (BLOCK) comes from Server.
        // it means that a user has blocked.
        case chatMessageVOTypes.BLOCK.rawValue:
            log.verbose("Message of type 'BLOCK' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.blockCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
            // a message of type 8 (UNBLOCK) comes from Server.
        // it means that a user has unblocked.
        case chatMessageVOTypes.UNBLOCK.rawValue:
            log.verbose("Message of type 'UNBLOCK' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.unblockCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
            // a message of type 9 (LEAVE_THREAD) comes from Server.
        // it means that a you has leaved the thread.
        case chatMessageVOTypes.LEAVE_THREAD.rawValue:
            log.verbose("Message of type 'LEAVE_THREAD' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.leaveThreadCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            
            // this functionality has beed deprecated
            /*
             let threadIds = messageContent["id"].intValue
             let paramsToSend: JSON = ["threadIds": threadIds]
             getThreads(params: paramsToSend, uniqueId: { _ in }) { (response) in
             
             let responseModel: GetThreadsModel = response as! GetThreadsModel
             let responseJSON: JSON = responseModel.returnDataAsJSON()
             let threads = responseJSON["result"]["threads"].array
             
             if let myThreads = threads {
             let result: JSON = ["thread": myThreads[0]]
             self.delegate?.threadEvents(type: "THREAD_LEAVE_PARTICIPANT", result: result)
             self.delegate?.threadEvents(type: "THREAD_LAST_ACTIVITY_TIME", result: result)
             } else {
             let result: JSON = ["threadId": threadId]
             self.delegate?.threadEvents(type: "THREAD_LEAVE_PARTICIPANT", result: result)
             }
             
             }
             */
            
            break
            
        // a message of type 10 (RENAME) comes from Server.
        case chatMessageVOTypes.RENAME.rawValue:
            //
            break
            
            // a message of type 11 (ADD_PARTICIPANT) comes from Server.
        // it means some participants added to the thread.
        case chatMessageVOTypes.ADD_PARTICIPANT.rawValue:
            log.verbose("Message of type 'ADD_PARTICIPANT' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.addParticipantsCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            
            // this functionality has beed deprecated
            /*
             let threadIds = messageContent["id"].intValue
             let paramsToSend: JSON = ["threadIds": threadIds]
             getThreads(params: paramsToSend, uniqueId: { _ in }) { (response) in
             let responseModel: GetThreadsModel = response as! GetThreadsModel
             let responseJSON: JSON = responseModel.returnDataAsJSON()
             let threads = responseJSON["result"]["threads"].arrayValue
             
             let result: JSON = ["thread": threads[0]]
             self.delegate?.threadEvents(type: "THREAD_ADD_PARTICIPANTS", result: result)
             self.delegate?.threadEvents(type: "THREAD_LAST_ACTIVITY_TIME", result: result)
             }
             */
            
            break
            
        // a message of type 12 (GET_STATUS) comes from Server.
        case chatMessageVOTypes.GET_STATUS.rawValue:
            //
            break
            
            // a message of type 13 (GET_CONTACTS) comes from Server.
        // it means array of contacts comes
        case chatMessageVOTypes.GET_CONTACTS.rawValue:
            log.verbose("Message of type 'GET_CONTACTS' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                
                
                
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.getContactsCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 14 (GET_THREADS) comes from Server.
        case chatMessageVOTypes.GET_THREADS.rawValue:
            log.verbose("Message of type 'GET_THREADS' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.threadsCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 15 (GET_HISTORY) comes from Server.
        case chatMessageVOTypes.GET_HISTORY.rawValue:
            log.verbose("Message of type 'GET_HISTORY' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.historyCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 16 (CHANGE_TYPE) comes from Server.
        case chatMessageVOTypes.CHANGE_TYPE.rawValue:
            break
            
        // a message of type 17 (REMOVED_FROM_THREAD) comes from Server.
        case chatMessageVOTypes.REMOVED_FROM_THREAD.rawValue:
            let result: JSON = ["thread": threadId]
            delegate?.threadEvents(type: ThreadEventTypes.removedFrom, result: result)
            break
            
        // a message of type 18 (REMOVE_PARTICIPANT) comes from Server.
        case chatMessageVOTypes.REMOVE_PARTICIPANT.rawValue:
            log.verbose("Message of type 'REMOVE_PARTICIPANT' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.removeParticipantsCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            //            let threadIds = threadId
            let paramsToSend: JSON = ["threadIds": threadId]
            getThreads(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
                let myResponseModel: GetThreadsModel = myResponse as! GetThreadsModel
                let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
                let threads = myResponseJSON["result"]["threads"].arrayValue
                
                let result: JSON = ["thread": threads[0]]
                self.delegate?.threadEvents(type: ThreadEventTypes.removeParticipant, result: result)
                self.delegate?.threadEvents(type: ThreadEventTypes.lastActivityTime, result: result)
            }
            break
            
        // a message of type 19 (MUTE_THREAD) comes from Server.
        case chatMessageVOTypes.MUTE_THREAD.rawValue:
            log.verbose("Message of type 'MUTE_THREAD' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: nil, resultAsString: messageContentAsString, contentCount: nil, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.muteThreadCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
                
                // this functionality has beed deprecated
                /*
                 let paramsToSend: JSON = ["threadIds": [threadId]]
                 getThreads(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
                 let myResponseModel: GetThreadsModel = myResponse as! GetThreadsModel
                 let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
                 let threads = myResponseJSON["result"]["threads"].arrayValue
                 
                 let result: JSON = ["thread": threads.first!]
                 self.delegate?.threadEvents(type: "THREAD_MUTE", result: result)
                 }
                 */
                
            }
            break
            
        // a message of type 20 (UNMUTE_THREAD) comes from Server.
        case chatMessageVOTypes.UNMUTE_THREAD.rawValue:
            log.verbose("Message of type 'UNMUTE_THREAD' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: nil, resultAsString: messageContentAsString, contentCount: nil, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.unmuteThreadCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
                
                // this functionality has beed deprecated
                /*
                 let paramsToSend: JSON = ["threadIds": [threadId]]
                 getThreads(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
                 let myResponseModel: GetThreadsModel = myResponse as! GetThreadsModel
                 let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
                 let threads = myResponseJSON["result"]["threads"].arrayValue
                 
                 let result: JSON = ["thread": threads.first!]
                 self.delegate?.threadEvents(type: "THREAD_UNMUTE", result: result)
                 }
                 */
                
            }
            break
            
        // a message of type 21 (UPDATE_THREAD_INFO) comes from Server.
        case chatMessageVOTypes.UPDATE_THREAD_INFO.rawValue:
            log.verbose("Message of type 'UPDATE_THREAD_INFO' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: nil, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.updateThreadInfoCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
                
                // this functionality has beed deprecated
                /*
                 let paramsToSend: JSON = ["threadIds": messageContent["id"].intValue]
                 getThreads(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
                 let myResponseModel: GetThreadsModel = myResponse as! GetThreadsModel
                 let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
                 let threads = myResponseJSON["result"]["threads"].arrayValue
                 let thread: JSON = ["thread": threads.first!]
                 let result: JSON = ["result": thread]
                 self.delegate?.threadEvents(type: "THREAD_INFO_UPDATED", result: result)
                 }
                 */
                
            }
            break
            
        // a message of type 22 (FORWARD_MESSAGE) comes from Server.
        case chatMessageVOTypes.FORWARD_MESSAGE.rawValue:
            log.verbose("Message of type 'FORWARD_MESSAGE' recieved", context: "Chat")
            chatMessageHandler(threadId: threadId, messageContent: messageContent)
            break
            
        // a message of type 23 (USER_INFO) comes from Server.
        case chatMessageVOTypes.USER_INFO.rawValue:
            log.verbose("Message of type 'USER_INFO' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: nil, subjectId: params["subjectId"].int)
                
                self.chatDelegateUserInfo(userInfo: returnData)
                
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (myUserInfoModel) in
                    self.getUserInfoRetryCount = 0
                    // here has to send callback to getuserInfo function
                    self.userInfoCallbackToUser?(myUserInfoModel)
                }) { (failureJSON) in
                    if (self.getUserInfoRetryCount > self.getUserInfoRetry) {
                        self.delegate?.chatError(errorCode: 6101, errorMessage: CHAT_ERRORS.err6001.rawValue, errorResult: nil)
                    } else {
                        self.handleAsyncReady()
                    }
                }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 24 (USER_STATUS) comes from Server.
        case chatMessageVOTypes.USER_STATUS.rawValue:
            break
            
        // a message of type 25 (GET_BLOCKED) comes from Server.
        case chatMessageVOTypes.GET_BLOCKED.rawValue:
            log.verbose("Message of type 'GET_BLOCKED' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.getBlockedCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 26 (RELATION_INFO) comes from Server.
        case chatMessageVOTypes.RELATION_INFO.rawValue:
            break
            
        // a message of type 27 (THREAD_PARTICIPANTS) comes from Server.
        case chatMessageVOTypes.THREAD_PARTICIPANTS.rawValue:
            log.verbose("Message of type 'THREAD_PARTICIPANTS' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.threadParticipantsCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 28 (EDIT_MESSAGE) comes from Server.
        case chatMessageVOTypes.EDIT_MESSAGE.rawValue:
            log.verbose("Message of type 'EDIT_MESSAGE' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.editMessageCallbackToUser?(successJSON)
                }) { _ in }
                chatEditMessageHandler(threadId: threadId, messageContent: messageContent)
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 29 (DELETE_MESSAGE) comes from Server.
        case chatMessageVOTypes.DELETE_MESSAGE.rawValue:
            log.verbose("Message of type 'DELETE_MESSAGE' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.deleteMessageCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 30 (THREAD_INFO_UPDATED) comes from Server.
        case chatMessageVOTypes.THREAD_INFO_UPDATED.rawValue:
            log.verbose("Message of type 'THREAD_INFO_UPDATED' recieved", context: "Chat")
            let conversation: Conversation = Conversation(messageContent: messageContent)
            let result: JSON = ["thread": conversation]
            delegate?.threadEvents(type: ThreadEventTypes.infoUpdated, result: result)
            break
            
        // a message of type 31 (LAST_SEEN_UPDATED) comes from Server.
        case chatMessageVOTypes.LAST_SEEN_UPDATED.rawValue:
            log.verbose("Message of type 'LAST_SEEN_UPDATED' recieved", context: "Chat")
            delegate?.threadEvents(type: ThreadEventTypes.lastSeenUpdate, result: messageContent)
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
        case chatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.rawValue:
            log.verbose("Message of type 'GET_MESSAGE_DELEVERY_PARTICIPANTS' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.getMessageDeliverListCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 33 (GET_MESSAGE_SEEN_PARTICIPANTS) comes from Server.
        case chatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.rawValue:
            log.verbose("Message of type 'GET_MESSAGE_SEEN_PARTICIPANTS' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.getMessageSeenListCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 40 (BOT_MESSAGE) comes from Server.
        case chatMessageVOTypes.BOT_MESSAGE.rawValue:
            log.verbose("Message of type 'BOT_MESSAGE' recieved", context: "Chat")
            //            let result: JSON = ["bot": messageContent]
            //            self.delegate?.botEvents(type: "BOT_MESSAGE", result: result)
            break
            
        // a message of type 41 (SPAM_PV_THREAD) comes from Server.
        case chatMessageVOTypes.SPAM_PV_THREAD.rawValue:
            log.verbose("Message of type 'SPAM_PV_THREAD' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: nil, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.spamPvThreadCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 42 (SET_RULE_TO_USER) comes from Server.
        case chatMessageVOTypes.SET_RULE_TO_USER.rawValue:
            log.verbose("Message of type 'SET_RULE_TO_USER' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                //                var result: JSON = messageContentAsString
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: nil, resultAsString: messageContentAsString, contentCount: nil, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.setRoleToUserCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 44 (CLEAR_HISTORY) comes from Server.
        case chatMessageVOTypes.CLEAR_HISTORY.rawValue:
            log.verbose("Message of type 'CLEAR_HISTORY' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: nil, resultAsString: messageContentAsString, contentCount: nil, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.clearHistoryCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 45 (SIGNAL_MESSAGE) comes from Server
        case chatMessageVOTypes.SIGNAL_MESSAGE.rawValue:
            log.verbose("Message of type 'SIGNAL_MESSAGE' revieved", context: "Chat")
            delegate?.threadEvents(type: ThreadEventTypes.isTyping, result: "\(messageContentAsString)")
            return
            
        // a message of type 48 (GET_THREAD_ADMINS) comes from Server.
        case chatMessageVOTypes.GET_THREAD_ADMINS.rawValue:
            log.verbose("Message of type 'GET_THREAD_ADMINS' recieved", context: "Chat")
            print("\n\n\n\n\n\n\n GETADMIN : \n \(messageContentAsString)\n\n\n\n")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: nil, resultAsString: messageContentAsString, contentCount: nil, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.getAdminListCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 100 (LOGOUT) comes from Server.
        case chatMessageVOTypes.LOGOUT.rawValue:
            break
            
        // a message of type 999 (ERROR) comes from Server.
        case chatMessageVOTypes.ERROR.rawValue:
            log.verbose("Message of type 'ERROR' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let message: String = messageContent["message"].stringValue
                let code: Int = messageContent["code"].intValue
                
                let returnData: JSON = createReturnData(hasError: true, errorMessage: message, errorCode: code, result: messageContent, resultAsString: nil, contentCount: 0, subjectId: params["subjectId"].int)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.spamPvThreadCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
                
                if (messageContent["code"].intValue == 21) {
                    chatState = false
                    asyncClient?.asyncLogOut()
                    //                    clearCache()
                }
                delegate?.chatError(errorCode: code, errorMessage: message, errorResult: messageContent)
            }
            break
            
        default:
            //            print("This type of message is not defined yet!!!")
            log.warning("This type of message is not defined yet!!!", context: "Chat")
            break
        }
    }
    
    
    
    
    func chatMessageHandler(threadId: Int, messageContent: JSON) {
        let message = Message(threadId: threadId, pushMessageVO: messageContent)
        
        let parameterToSent: JSON = ["messageId":   message.id ?? NSNull(),
                                     "participant": message.participant?.id ?? NSNull()]
        deliver(params: parameterToSent)
        
        if let messageParticipants = message.participant {
            delegate?.chatDeliver(messageId: message.id!, ownerId: messageParticipants.id!)
        }
        
        let messageJSON = message.formatToJSON()
        let myResult: JSON = ["message": messageJSON]
        delegate?.messageEvents(type: MessageEventTypes.new, result: myResult)
        
        
        // This code is deprecated
        //        let myThreadId: JSON = ["threadIds": threadId]
        //        getThreads(params: myThreadId, uniqueId: { _ in }) { (threadsResult) in
        //            let threadsResultModel: GetThreadsModel = threadsResult as! GetThreadsModel
        //            let threadsResultJSON: JSON = threadsResultModel.returnDataAsJSON()
        //
        //            let threads = threadsResultJSON["result"]["threads"].arrayValue
        //
        //            if (messageContent["participant"]["id"].intValue != self.userInfo!["id"].intValue) {
        //                let result: JSON = ["thread": threads[0].intValue,
        //                                    "messageId": messageContent["id"].intValue,
        //                                    "senderId": messageContent["participant"]["id"].intValue]
        //                self.delegate?.threadEvents(type: "THREAD_UNREAD_COUNT_UPDATED", result: result)
        //            }
        //
        //            let result: JSON = ["thread": threads[0].intValue]
        //            self.delegate?.threadEvents(type: "THREAD_LAST_ACTIVITY_TIME", result: result)
        //        }
        
    }
    
    
    func chatEditMessageHandler(threadId: Int, messageContent: JSON) {
        let message = Message(threadId: threadId, pushMessageVO: messageContent)
        let result: JSON = ["message": message]
        delegate?.messageEvents(type: MessageEventTypes.edit, result: result)
    }
    
    
    
    
    
    // i created a class for this method to do the same exat functionality
    
    func createReturnData(hasError: Bool, errorMessage: String?, errorCode: Int?, result: JSON?, resultAsString: String?, contentCount: Int?, subjectId: Int?) -> JSON {
        
        
        let hasErr = hasError
        
        let errMsg: String
        var errCode: Int
        var contCount: Int
        if let theErrMsg = errorMessage {
            errMsg = theErrMsg
        } else {
            errMsg = ""
        }
        if let errC = errorCode {
            errCode = errC
        } else {
            errCode = 0
        }
        if let theCount = contentCount {
            contCount = theCount
        } else {
            contCount = 0
        }
        
        var obj: JSON = ["hasError": hasErr,
                         "errorMessage": errMsg,
                         "errorCode": errCode,
                         "result": NSNull(),
                         "contentCount": contCount,
                         "subjectId": subjectId ?? NSNull()]
        
        if let myResult = result {
            obj["result"] = myResult
        } else if let myResult = resultAsString {
            obj["result"] = JSON(myResult)
        }
        
        return obj
    }
    
    
    
    
}



