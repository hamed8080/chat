//
//  Chat.swift
//  Chat
//
//  Created by Mahyar Zhiani on 5/21/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import Contacts
import CoreData
import Alamofire
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK
import UIKit


public class Chat {
    
    // the delegate property that the user class should make itself to be implment this delegat.
    // At first, the class sould confirm to ChatDelegates, and then implement the ChatDelegates methods
    public weak var delegate: ChatDelegates?
    
    // create cache instance to use cache...
    static let cacheDB = Cache()
    
    
    // MARK: - setup properties
    
    var socketAddress:  String  = ""        // Address of the Socket Server
    var ssoHost:        String  = ""        // Address of the SSO Server (SERVICE_ADDRESSES.SSO_ADDRESS)
    var platformHost:   String  = ""        // Address of the platform (SERVICE_ADDRESSES.PLATFORM_ADDRESS)
    var fileServer:     String  = ""        // Address of the FileServer (SERVICE_ADDRESSES.FILESERVER_ADDRESS)
    var serverName:     String  = ""        // Name of the server that we had registered on
    var token:          String  = ""        // every user have to had a token (get it from SSO Server)
    var generalTypeCode:    String  = "default"
    var enableCache:        Bool    = false
    var mapApiKey:          String  = "8b77db18704aa646ee5aaea13e7370f4f88b9e8c"
    var mapServer:          String  = "https://api.neshan.org/v1"
    
    //    var ssoGrantDevicesAddress = params.ssoGrantDevicesAddress
    var chatFullStateObject: JSON = [:]
    
    var msgPriority:        Int
    var msgTTL:             Int
    var httpRequestTimeout: Int
    var actualTimingLog:    Bool
    
    var wsConnectionWaitTime:       Double
    var connectionRetryInterval:    Int
    var connectionCheckTimeout:     Int
    var messageTtl:                 Int
    var reconnectOnClose:           Bool
    
//    var imageMimeTypes = ["image/bmp", "image/png", "image/tiff", "image/gif", "image/x-icon", "image/jpeg", "image/webp"]
//    var imageExtentions = ["bmp", "png", "tiff", "tiff2", "gif", "ico", "jpg", "jpeg", "webp"]
    
    var asyncClient:    Async?
    var deviceId:       String?
    var peerId:         Int?
    var oldPeerId:      Int?
    var userInfo:       User?
    
    var getHistoryCount         = 50
    var getUserInfoRetry        = 5
    var getUserInfoRetryCount   = 0
    var chatPingMessageInterval = 20
    var lastReceivedMessageTime:        Date?
    var lastReceivedMessageTimeoutId:   RepeatingTimer?
    var lastSentMessageTime:            Date?
    var lastSentMessageTimeoutId:       RepeatingTimer?
    var chatState = false
    var cacheTimeStamp = (2 * 24) * (60 * 60)
    
    var SERVICE_ADDRESSES = SERVICE_ADDRESSES_ENUM()
    
    private var uploadRequest:      [(upload: Request, uniqueId: String)]   = []
    private var downloadRequest:    [(download: Request, uniqueId: String)] = []
    
    // MARK: - Chat initializer
    
    public init(socketAddress:              String,
                ssoHost:                    String,
                platformHost:               String,
                fileServer:                 String,
                serverName:                 String,
                token:                      String,
                mapApiKey:                  String?,
                mapServer:                  String,
                typeCode:                   String?,
                enableCache:                Bool,
                cacheTimeStampInSec:        Int?,
                msgPriority:                Int?,
                msgTTL:                     Int?,
                httpRequestTimeout:         Int?,
                actualTimingLog:            Bool?,
                wsConnectionWaitTime:       Double,
                connectionRetryInterval:    Int,
                connectionCheckTimeout:     Int,
                messageTtl:                 Int,
                reconnectOnClose:           Bool) {
        
        //        Chat.cacheDB.deleteCacheData()
        
        self.socketAddress      = socketAddress
        self.ssoHost            = ssoHost
        self.platformHost       = platformHost
        self.fileServer         = fileServer
        self.serverName         = serverName
        self.token              = token
        self.enableCache        = enableCache
        self.mapServer          = mapServer
        
        if let timeStamp = cacheTimeStampInSec {
            cacheTimeStamp = timeStamp
        }
        
        if let theMapApiKey = mapApiKey {
            self.mapApiKey = theMapApiKey
        }
        
        if let theTypeCode = typeCode {
            self.generalTypeCode = theTypeCode
        }
        
        if let theMsgPriority = msgPriority {
            self.msgPriority = theMsgPriority
        } else {
            self.msgPriority = 1
        }
        
        if let theMsgTTL = msgTTL {
            self.msgTTL = theMsgTTL
        } else {
            self.msgTTL = 10
        }
        
        if let theMsgTTL = msgTTL {
            self.msgTTL = theMsgTTL
        } else {
            self.msgTTL = 10
        }
        
        if let theHttpRequestTimeout = httpRequestTimeout {
            self.httpRequestTimeout = theHttpRequestTimeout
        } else {
            self.httpRequestTimeout = 20
        }
        
        if let theActualTimingLog = actualTimingLog {
            self.actualTimingLog = theActualTimingLog
        } else {
            self.actualTimingLog = false
        }
        
        self.wsConnectionWaitTime   = wsConnectionWaitTime
        self.connectionRetryInterval = connectionRetryInterval
        self.connectionCheckTimeout = connectionCheckTimeout
        self.messageTtl             = messageTtl
        self.reconnectOnClose       = reconnectOnClose
        
        self.SERVICE_ADDRESSES.SSO_ADDRESS          = ssoHost
        self.SERVICE_ADDRESSES.PLATFORM_ADDRESS     = platformHost
        self.SERVICE_ADDRESSES.FILESERVER_ADDRESS   = fileServer
        self.SERVICE_ADDRESSES.MAP_ADDRESS          = mapServer
        
        getDeviceIdWithToken { (deviceIdStr) in
            self.deviceId = deviceIdStr
            
            log.verbose("get deviceId successfully = \(self.deviceId ?? "error!!")", context: "Chat")
            
            DispatchQueue.main.async {
                self.CreateAsync()
            }
        }
        
    }
    
    
    // MARK: - create Async with the parameters
    
    public func CreateAsync() {
        if let dId = deviceId {
            asyncClient = Async(socketAddress: socketAddress, serverName: serverName, deviceId: dId, appId: nil, peerId: nil, messageTtl: messageTtl, connectionRetryInterval: connectionRetryInterval, reconnectOnClose: reconnectOnClose)
            asyncClient?.delegate = self
            asyncClient?.createSocket()
        }
    }
    
    
    // MARK: - properties that save callbacks on themselves
    
    // property to hold array of request that comes from client, but they have not completed yet, and response didn't come yet.
    // the keys are uniqueIds of the requests
    static var map = [String: CallbackProtocol]()
    
    // property to hold array of Sent requests that comes from client, but they have not completed yet, and response didn't come yet.
    // the keys are uniqueIds of the requests
    static var mapOnSent = [String: CallbackProtocolWith3Calls]()
    
    // property to hold array of Deliver and Seen requests that comes from client, but they have not completed yet, and response didn't come yet.
    // first keys are threadIds
    // second keys are uniqueIds of the request
    static var mapOnDeliver = [String: [[String: CallbackProtocolWith3Calls]]]()
    static var mapOnSeen = [String: [[String: CallbackProtocolWith3Calls]]]()
    
    // property to hold Sent callbecks to implement later, on somewhere else on the program
    private var userInfoCallbackToUser:             callbackTypeAlias?
    private var getContactsCallbackToUser:          callbackTypeAlias?
    private var threadsCallbackToUser:              callbackTypeAlias?
    private var historyCallbackToUser:              callbackTypeAlias?
    private var threadParticipantsCallbackToUser:   callbackTypeAlias?
    private var createThreadCallbackToUser:         callbackTypeAlias?
    private var addParticipantsCallbackToUser:      callbackTypeAlias?
    private var removeParticipantsCallbackToUser:   callbackTypeAlias?
    private var sendCallbackToUserOnSent:           callbackTypeAlias?
    private var sendCallbackToUserOnDeliver:        callbackTypeAlias?
    private var sendCallbackToUserOnSeen:           callbackTypeAlias?
    private var editMessageCallbackToUser:          callbackTypeAlias?
    private var deleteMessageCallbackToUser:        callbackTypeAlias?
    private var muteThreadCallbackToUser:           callbackTypeAlias?
    private var unmuteThreadCallbackToUser:         callbackTypeAlias?
    private var updateThreadInfoCallbackToUser:     callbackTypeAlias?
    private var blockCallbackToUser:                callbackTypeAlias?
    private var unblockCallbackToUser:              callbackTypeAlias?
    private var getBlockedCallbackToUser:           callbackTypeAlias?
    private var leaveThreadCallbackToUser:          callbackTypeAlias?
    private var spamPvThreadCallbackToUser:         callbackTypeAlias?
    private var getMessageSeenListCallbackToUser:   callbackTypeAlias?
    private var getMessageDeliverListCallbackToUser: callbackTypeAlias?
    private var clearHistoryCallbackToUser:         callbackTypeAlias?
    
//    var tempSendMessageArr:     [[String : JSON]]   = []
//    var tempReceiveMessageArr:  [[String: JSON]]    = []
    
    public func setGetUserInfoRetryCount(value: Int) {
        getUserInfoRetryCount = value
    }
    public func getGetUserInfoRetryCount() -> Int {
        return getUserInfoRetryCount
    }
    public func getGetUserInfoRetry() -> Int {
        return getUserInfoRetry
    }
    
}


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
                
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
                
                
                
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: nil, resultAsString: messageContentAsString, contentCount: nil)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: nil, resultAsString: messageContentAsString, contentCount: nil)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: nil)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: nil)
                
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
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
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: nil)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.spamPvThreadCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 42 (SET_RULE_TO_USER) comes from Server.
        case chatMessageVOTypes.SET_RULE_TO_USER.rawValue:
            break
            
        // a message of type 44 (CLEAR_HISTORY) comes from Server.
        case chatMessageVOTypes.CLEAR_HISTORY.rawValue:
            log.verbose("Message of type 'CLEAR_HISTORY' recieved", context: "Chat")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: nil, resultAsString: messageContentAsString, contentCount: nil)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.clearHistoryCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        // a message of type 48 (GET_THREAD_ADMINS) comes from Server.
        case chatMessageVOTypes.GET_THREAD_ADMINS.rawValue:
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
    
                    let returnData: JSON = createReturnData(hasError: true, errorMessage: message, errorCode: code, result: messageContent, resultAsString: nil, contentCount: 0)
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
    
    
    
    
    
    
    func createReturnData(hasError: Bool, errorMessage: String?, errorCode: Int?, result: JSON?, resultAsString: String?, contentCount: Int?) -> JSON {
        
        
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
                         "contentCount": contCount]
        if let myResult = result {
            obj["result"] = myResult
        } else if let myResult = resultAsString {
            obj["result"] = JSON(myResult)
        }
        
        return obj
    }
    
    
    
    
}


// MARK: -
// MARK: - Public Methods

extension Chat {
    
    // MARK: - User Management
    
    /*
     This function will retuen peerId of the current user if it exists, else it would return 0
     */
    public func getPeerId() -> Int {
        if let id = peerId {
            return id
        } else {
            return 0
        }
    }
    
    /*
     This function will return the current user info if it exists, otherwise it would return nil!
     */
    public func getCurrentUser() -> User? {
        if let myUserInfo = userInfo {
            return myUserInfo
        } else {
            return nil
        }
    }
    
    
    /*
     GetUserInfo:
     it returns UserInfo.
     
     By calling this function, a request of type 23 (USER_INFO) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this method doesn't need any input
     
     + Outputs:
     It has 3 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (UserInfoModel)
     3- cacheResponse:  there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     */
    public func getUserInfo(uniqueId:       @escaping (String) -> (),
                            completion:     @escaping callbackTypeAlias,
                            cacheResponse:  @escaping (UserInfoModel) -> ()) {
        log.verbose("Try to request to get user info", context: "Chat")
        userInfoCallbackToUser = completion
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.USER_INFO.rawValue,
                                       "typeCode": generalTypeCode]
        
        sendMessageWithCallback(params: sendMessageParams, callback: UserInfoCallback(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getUserInfoUniqueId) in
            uniqueId(getUserInfoUniqueId)
        }
        
        
        
        // if cache is enabled by user, first return cache result to the user
        if enableCache {
            if let cacheUserInfoResult = Chat.cacheDB.retrieveUserInfo() {
                cacheResponse(cacheUserInfoResult)
            }
        }
        
    }
    
    
    // MARK: - Contact Management
    
    /*
     GetContacts:
     it returns list of contacts
     
     By calling this function, a request of type 13 (GET_CONTACTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - count:    how many contact do you want to get with this request.      (Int)       -optional-  , if you don't set it, it would have default value of 50
     - offset:   offset of the contact number that start to count to show.   (Int)       -optional-  , if you don't set it, it would have default value of 0
     - name:     if you want to search on your contact, put it here.         (String)    -optional-  ,
     - typeCode:
     
     + Outputs:
     It has 3 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (GetContactsModel)
     3- cacheResponse:  there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     */
    public func getContacts(getContactsInput:   GetContactsRequestModel,
                            uniqueId:           @escaping (String) -> (),
                            completion:         @escaping callbackTypeAlias,
                            cacheResponse:      @escaping (GetContactsModel) -> ()) {
        log.verbose("Try to request to get Contacts with this parameters: \n \(getContactsInput)", context: "Chat")
        
        var content: JSON = [:]
        
        content["count"]    = JSON(getContactsInput.count ?? 50)
        content["size"]     = JSON(getContactsInput.count ?? 50)
        content["offset"]   = JSON(getContactsInput.offset ?? 0)
        
        if let name = getContactsInput.name {
            content["name"] = JSON(name)
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_CONTACTS.rawValue,
                                       //                                       "typeCode": getContactsInput.typeCode ?? generalTypeCode,
            "content": content]
        sendMessageWithCallback(params: sendMessageParams, callback: GetContactsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getContactUniqueId) in
            uniqueId(getContactUniqueId)
        }
        getContactsCallbackToUser = completion
        
        
        // if cache is enabled by user, it will return cache result to the user
        if enableCache {
            if let cacheContacts = Chat.cacheDB.retrieveContacts(ascending:         true,
                                                                 cellphoneNumber:   nil,
                                                                 count:     getContactsInput.count ?? 50,
                                                                 email:     nil,
                                                                 firstName: nil,
                                                                 id:        nil,
                                                                 lastName:  nil,
                                                                 offset:    getContactsInput.offset ?? 0,
                                                                 search:    getContactsInput.name,
                                                                 timeStamp: cacheTimeStamp,
                                                                 uniqueId:  nil) {
                cacheResponse(cacheContacts)
            }
        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'GetContactsRequestModel' to get the parameters, it'll use JSON
    public func getContacts(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get Contacts with this parameters: \n \(params ?? "params is empty!")", context: "Chat")
        
        var myTypeCode: String = generalTypeCode
        var content: JSON = ["count": 50, "offset": 0]
        if let parameters = params {
            if let count = parameters["count"].int {
                if count > 0 {
                    content["count"] = JSON(count)
                    content["size"] = JSON(count)
                }
            }
            
            if let offset = parameters["offset"].int {
                if offset > 0 {
                    content["offset"] = JSON(offset)
                }
            }
            
            if let name = parameters["name"].string {
                content["name"] = JSON(name)
            }
            
            if let typeCode = parameters["typeCode"].string {
                myTypeCode = typeCode
            }
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_CONTACTS.rawValue,
                                       "typeCode": myTypeCode,
                                       "content": content]
        sendMessageWithCallback(params: sendMessageParams, callback: GetContactsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getContactUniqueId) in
            uniqueId(getContactUniqueId)
        }
        getContactsCallbackToUser = completion
    }
    
    
    /*
     AddContact:
     it will add a contact
     
     By calling this function, HTTP request of type (ADD_CONTACTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - firstName:       first name of the contact.      (String)    , at least one of 'firstName' or 'lastName' is necessery, the other one is optional.
     - lastName:        last name of the contact.       (String)    , at least one of 'firstName' or 'lastName' is necessery, the other one is optional.
     - cellphoneNumber: phone number of the contact.    (String)    , at least one of 'cellphoneNumber' or 'email' is necessery, the other one is optional.
     - email:           email of the contact.           (String)    , at least one of 'cellphoneNumber' or 'email' is necessery, the other one is optional.
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (ContactModel)
     */
    public func addContact(addContactsInput:    AddContactsRequestModel,
                           uniqueId:            @escaping (String) -> (),
                           completion:          @escaping callbackTypeAlias) {
        log.verbose("Try to request to add contact with this parameters: \n \(addContactsInput)", context: "Chat")
        
        var data: Parameters = [:]
        
        data["firstName"] = JSON(addContactsInput.firstName ?? "")
        data["lastName"] = JSON(addContactsInput.lastName ?? "")
        data["cellphoneNumber"] = JSON(addContactsInput.cellphoneNumber ?? "")
        data["email"] = JSON(addContactsInput.email ?? "")
        
        let messageUniqueId: String = generateUUID()
        data["uniqueId"] = JSON(messageUniqueId)
        uniqueId(messageUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.ADD_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: messageUniqueId, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            
            // save data comes from server to the Cache
            let messageContent: [JSON] = jsonRes["result"].arrayValue
            var contactsArr = [Contact]()
            for item in messageContent {
                let myContact = Contact(messageContent: item)
                contactsArr.append(myContact)
            }
            Chat.cacheDB.saveContactObjects(contacts: contactsArr)
            
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'AddContactsRequestModel' to get the parameters, it'll use JSON
    public func addContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to add contact with this parameters: \n \(params)", context: "Chat")
        
        var data: Parameters = [:]
        
        if let firstName = params["firstName"].string {
            data["firstName"] = JSON(firstName)
        } else { data["firstName"] = JSON("") }
        
        if let lastName = params["lastName"].string {
            data["lastName"] = JSON(lastName)
        } else { data["lastName"] = JSON("") }
        
        if let cellphoneNumber = params["cellphoneNumber"].string {
            data["cellphoneNumber"] = JSON(cellphoneNumber)
        } else { data["cellphoneNumber"] = JSON("") }
        
        if let email = params["email"].string {
            data["email"] = JSON(email)
        } else { data["email"] = JSON("") }
        
        let messageUniqueId: String = generateUUID()
        data["uniqueId"] = JSON(messageUniqueId)
        uniqueId(messageUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.ADD_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: messageUniqueId, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    
    
    /*
     UpdateContact:
     it will update an existing contact
     
     By calling this function, HTTP request of type (UPDATE_CONTACTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - id:              id of the contact that you want to update its data.  (Int)
     - firstName:       first name of the contact.                           (String)
     - lastName:        last name of the contact.                            (String)
     - cellphoneNumber: phone number of the contact.                         (String)
     - email:           email of the contact.                                (String)
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (ContactModel)
     */
    public func updateContact(updateContactsInput:  UpdateContactsRequestModel,
                              uniqueId:             @escaping (String) -> (),
                              completion:           @escaping callbackTypeAlias) {
        log.verbose("Try to request to update contact with this parameters: \n \(updateContactsInput)", context: "Chat")
        
        var data: Parameters = [:]
        
        data["id"]              = JSON(updateContactsInput.id)
        data["firstName"]       = JSON(updateContactsInput.firstName)
        data["lastName"]        = JSON(updateContactsInput.lastName)
        data["cellphoneNumber"] = JSON(updateContactsInput.cellphoneNumber)
        data["email"]           = JSON(updateContactsInput.email)
        
        let messageUniqueId: String = generateUUID()
        data["uniqueId"] = JSON(messageUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.UPDATE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: messageUniqueId, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'UpdateContactsRequestModel' to get the parameters, it'll use JSON
    public func updateContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to update contact with this parameters: \n \(params)", context: "Chat")
        
        var data: Parameters = [:]
        
        if let id = params["id"].int {
            data["id"] = JSON(id)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "ID is required for Updating Contact!", errorResult: nil)
        }
        
        if let firstName = params["firstName"].string {
            data["firstName"] = JSON(firstName)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "firstName is required for Updating Contact!", errorResult: nil)
        }
        
        if let lastName = params["lastName"].string {
            data["lastName"] = JSON(lastName)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "lastName is required for Updating Contact!", errorResult: nil)
        }
        
        if let cellphoneNumber = params["cellphoneNumber"].string {
            data["cellphoneNumber"] = JSON(cellphoneNumber)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "cellphoneNumber is required for Updating Contact!", errorResult: nil)
        }
        
        if let email = params["email"].string {
            data["email"] = JSON(email)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "email is required for Updating Contact!", errorResult: nil)
        }
        
        let uniqueId: String = generateUUID()
        data["uniqueId"] = JSON(uniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.UPDATE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: uniqueId, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    
    
    /*
     RemoveContact:
     remove a contact
     
     By calling this function, HTTP request of type (REMOVE_CONTACTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get one prameter as inputs, in the format of JSON or Model (depends on the function that you would use) which is:
     - id:              id of the contact that you want to remove it.   (Int)
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (RemoveContactModel)
     */
    public func removeContact(removeContactsInput:  RemoveContactsRequestModel,
                              uniqueId:             @escaping (String) -> (),
                              completion:           @escaping callbackTypeAlias) {
        log.verbose("Try to request to remove contact with this parameters: \n \(removeContactsInput)", context: "Chat")
        
        var data: Parameters = [:]
        
        data["id"] = JSON(removeContactsInput.id)
        
        let theUniqueId: String = generateUUID()
        data["uniqueId"] = JSON(theUniqueId)
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.REMOVE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: theUniqueId, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = RemoveContactModel(messageContent: jsonRes)
            
            // save deleting changes on the cache
            if (contactsResult.result) {
                Chat.cacheDB.deleteContact(withContactIds: [removeContactsInput.id])
            }
            
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'RemoveContactsRequestModel' to get the parameters, it'll use JSON
    public func removeContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to remove contact with this parameters: \n \(params)", context: "Chat")
        
        var data: Parameters = [:]
        
        if let id = params["id"].int {
            data["id"] = JSON(id)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "ID is required for Deleting Contact!", errorResult: nil)
        }
        
        let uniqueId: String = generateUUID()
        data["uniqueId"] = JSON(uniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.REMOVE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: uniqueId, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = RemoveContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    
    
    /*
     BlockContact:
     block a contact by its contactId.
     
     By calling this function, a request of type 7 (BLOCK) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - contactId:    id of your contact that you want to remove it.      (Int)
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (BlockedContactModel)
     */
    public func blockContact(blockContactsInput:    BlockContactsRequestModel,
                             uniqueId:              @escaping (String) -> (),
                             completion:            @escaping callbackTypeAlias) {
        log.verbose("Try to request to block user with this parameters: \n \(blockContactsInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.BLOCK.rawValue,
                                       "typeCode": blockContactsInput.typeCode ?? generalTypeCode]
        
        var content: JSON = [:]
        if let contactId = blockContactsInput.contactId {
            content["contactId"] = JSON(contactId)
        }
        if let threadId = blockContactsInput.threadId {
            content["threadId"] = JSON(threadId)
        }
        if let userId = blockContactsInput.userId {
            content["userId"] = JSON(userId)
        }
        
        sendMessageParams["content"] = JSON("\(content)")
        
        sendMessageWithCallback(params: sendMessageParams, callback: BlockContactCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (blockUniqueId) in
            uniqueId(blockUniqueId)
        }
        blockCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'BlockContactsRequestModel' to get the parameters, it'll use JSON
    public func blockContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to block user with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.BLOCK.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode]
        
        var content: JSON = [:]
        
        if let contactId = params["contactId"].int {
            content["contactId"] = JSON(contactId)
        }
        
        sendMessageParams["content"] = JSON("\(content)")
        
        sendMessageWithCallback(params: sendMessageParams, callback: BlockContactCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (blockUniqueId) in
            uniqueId(blockUniqueId)
        }
        blockCallbackToUser = completion
    }
    
    
    /*
     GetBlockContactsList:
     it returns a list of the blocked contacts.
     
     By calling this function, a request of type 25 (GET_BLOCKED) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - count:        how many contact do you want to give with this request.   (Int)
     - offset:       offset of the contact number that start to count to show.   (Int)
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (GetBlockedContactListModel)
     */
    public func getBlockedContacts(getBlockedContactsInput: GetBlockedContactListRequestModel,
                                   uniqueId:                @escaping (String) -> (),
                                   completion:              @escaping callbackTypeAlias) {
        log.verbose("Try to request to get block users with this parameters: \n \(getBlockedContactsInput)", context: "Chat")
        
        var content: JSON = [:]
        content["count"]    = JSON(getBlockedContactsInput.count ?? 50)
        content["offset"]   = JSON(getBlockedContactsInput.offset ?? 0)
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_BLOCKED.rawValue,
                                       "typeCode": getBlockedContactsInput.typeCode ?? generalTypeCode,
                                       "content": content]
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetBlockedContactsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getBlockedUniqueId) in
            uniqueId(getBlockedUniqueId)
        }
        getBlockedCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'GetBlockedContactListRequestModel' to get the parameters, it'll use JSON
    public func getBlockedContacts(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get block users with this parameters: \n \(params ?? "there isn't any parameter")", context: "Chat")
        
        var myTypeCode = generalTypeCode
        
        var content: JSON = ["count": 50, "offset": 0]
        if let parameters = params {
            
            if let count = parameters["count"].int {
                if count > 0 {
                    content.appendIfDictionary(key: "count", json: JSON(count))
                }
            }
            
            if let offset = parameters["offset"].int {
                if offset > 0 {
                    content.appendIfDictionary(key: "offset", json: JSON(offset))
                }
            }
            
            if let typeCode = parameters["typeCode"].string {
                myTypeCode = typeCode
            }
            
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_BLOCKED.rawValue,
                                       "typeCode": myTypeCode,
                                       "content": content]
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetBlockedContactsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getBlockedUniqueId) in
            uniqueId(getBlockedUniqueId)
        }
        getBlockedCallbackToUser = completion
    }
    
    
    /*
     UnblockContact:
     unblock a contact from blocked list.
     
     By calling this function, a request of type 8 (UNBLOCK) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - blockId:    id of your contact that you want to unblock it (remove this id from blocked list).  (Int)
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (BlockedContactModel)
     */
    public func unblockContact(unblockContactsInput:    UnblockContactsRequestModel,
                               uniqueId:                @escaping (String) -> (),
                               completion:              @escaping callbackTypeAlias) {
        log.verbose("Try to request to unblock user with this parameters: \n \(unblockContactsInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UNBLOCK.rawValue,
                                       "typeCode": unblockContactsInput.typeCode ?? generalTypeCode]
        if let subjectId = unblockContactsInput.blockId {
            sendMessageParams["subjectId"] = JSON(subjectId)
        }
        
        var content: JSON = [:]
        if let contactId = unblockContactsInput.contactId {
            content["contactId"] = JSON(contactId)
        }
        if let threadId = unblockContactsInput.threadId {
            content["threadId"] = JSON(threadId)
        }
        if let userId = unblockContactsInput.userId {
            content["userId"] = JSON(userId)
        }
        
        sendMessageParams["content"] = JSON("\(content)")
        
        sendMessageWithCallback(params: sendMessageParams, callback: UnblockContactCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (blockUniqueId) in
            uniqueId(blockUniqueId)
        }
        unblockCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'UnblockContactsRequestModel' to get the parameters, it'll use JSON
    public func unblockContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to unblock user with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UNBLOCK.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode]
        
        if let subjectId = params["blockId"].int {
            sendMessageParams["subjectId"] = JSON(subjectId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: UnblockContactCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (blockUniqueId) in
            uniqueId(blockUniqueId)
        }
        unblockCallbackToUser = completion
    }
    
    
    /*
     SearchContact:
     search contact and returns a list of contact.
     
     By calling this function, HTTP request of type (SEARCH_CONTACTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some prameters as inputs, in the format of JSON or Model (depends on the function that you would use) which are:
     - firstName:        firstName of the contacts that match with this parameter.       (String)    -optional-
     - lastName:         lastName of the contacts that match with this parameter.        (String)    -optional-
     - cellphoneNumber:  cellphoneNumber of the contacts that match with this parameter. (String)    -optional-
     - email:            email of the contacts that match with this parameter.           (String)    -optional-
     - uniqueId:         if you want, you can set the unique id of your request here     (String)    -optional-
     - size:             how many contact do you want to give with this request.         (Int)       -optional-  , if you don't set it, it would have default value of 50
     - offset:           offset of the contact number that start to count to show.       (Int)       -optional-  , if you don't set it, it would have default value of 0
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (ContactModel)
     */
    public func searchContacts(searchContactsInput: SearchContactsRequestModel,
                               uniqueId:            @escaping (String) -> (),
                               completion:          @escaping callbackTypeAlias,
                               cacheResponse:       @escaping (GetContactsModel) -> ()) {
        log.verbose("Try to request to search contact with this parameters: \n \(searchContactsInput)", context: "Chat")
        
        var data: Parameters = [:]
        
        data["size"] = JSON(searchContactsInput.size ?? 50)
        data["offset"] = JSON(searchContactsInput.offset ?? 0)
        
        if let firstName = searchContactsInput.firstName {
            data["firstName"] = JSON(firstName)
        }
        
        if let lastName = searchContactsInput.lastName {
            data["lastName"] = JSON(lastName)
        }
        
        if let cellphoneNumber = searchContactsInput.cellphoneNumber {
            data["cellphoneNumber"] = JSON(cellphoneNumber)
        }
        
        if let email = searchContactsInput.email {
            data["email"] = JSON(email)
        }
        
        if let uniqueId = searchContactsInput.uniqueId {
            data["uniqueId"] = JSON(uniqueId)
        }
        
        
        if enableCache {
            if let cacheContacts = Chat.cacheDB.retrieveContacts(ascending: true,
                                                                 cellphoneNumber: searchContactsInput.cellphoneNumber,
                                                                 count:     searchContactsInput.size ?? 50,
                                                                 email:     searchContactsInput.email,
                                                                 firstName: searchContactsInput.firstName,
                                                                 id:        nil,
                                                                 lastName:  searchContactsInput.lastName,
                                                                 offset:    searchContactsInput.offset ?? 0,
                                                                 search:    nil,
                                                                 timeStamp: cacheTimeStamp,
                                                                 uniqueId:  searchContactsInput.uniqueId) {
                cacheResponse(cacheContacts)
            }
        }
        
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.SEARCH_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: nil, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            
            //            // save data comes from server to the Cache
            //            var contacts = [Contact]()
            //            for item in jsonRes {
            //                let myContact = Contact(messageContent: item)
            //                contacts.append(myContact)
            //            }
            //            Chat.cacheDB.saveContactObjects(contacts: contacts)
            
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'SearchContactsRequestModel' to get the parameters, it'll use JSON
    public func searchContacts(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to search contact with this parameters: \n \(params)", context: "Chat")
        
        var data: Parameters = [:]
        
        if let firstName = params["firstName"].string {
            data["firstName"] = JSON(firstName)
        }
        
        if let lastName = params["lastName"].string {
            data["lastName"] = JSON(lastName)
        }
        
        if let cellphoneNumber = params["cellphoneNumber"].string {
            data["cellphoneNumber"] = JSON(cellphoneNumber)
        }
        
        if let email = params["email"].string {
            data["email"] = JSON(email)
        }
        
        if let id = params["id"].int {
            data["id"] = JSON(id)
        }
        
        if let q = params["q"].string {
            data["q"] = JSON(q)
        }
        
        if let uniqueId = params["uniqueId"].string {
            data["uniqueId"] = JSON(uniqueId)
        }
        
        if let size = params["size"].int {
            data["size"] = JSON(size)
        } else { data["size"] = JSON(50) }
        
        if let offset = params["offset"].int {
            data["offset"] = JSON(offset)
        } else { data["offset"] = JSON(0) }
        
        if let typeCode = params["typeCode"].string {
            data["typeCode"] = JSON(typeCode)
        } else {
            data["typeCode"] = JSON(generalTypeCode)
        }
        
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.SEARCH_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, requestUniqueId: nil, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    
    
    /*
     SyncContact:
     sync contacts from the client contact with Chat contact.
     
     By calling this function, HTTP request of type (SEARCH_CONTACTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function doesn't give any parameters as input
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response for each contact creation.                 (ContactModel)
     */
    public func syncContacts(uniqueId:      @escaping (String) -> (),
                             completion:    @escaping callbackTypeAlias,
                             cacheResponse: @escaping ([ContactModel]) -> ()) {
        log.verbose("Try to request to sync contact", context: "Chat")
        
        let myUniqueId = generateUUID()
        uniqueId(myUniqueId)
        
        // use this to send addcontact reqeusst as an Array
        //        var firstNameArray = [String]()
        //        var lastNameArray = [String]()
        //        var cellphoneNumberArray = [String]()
        //        var emailArray = [String]()
        
        var phoneContacts = [AddContactsRequestModel]()
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let _ = error {
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey,
                            CNContactFamilyNameKey,
                            CNContactPhoneNumbersKey,
                            CNContactEmailAddressesKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        let firstName = contact.givenName
                        let lastName = contact.familyName
                        let phoneNumber = contact.phoneNumbers.first?.value.stringValue
                        let emailAddress = contact.emailAddresses.first?.value
                        
                        let contact = AddContactsRequestModel(cellphoneNumber: phoneNumber, email: emailAddress as String?, firstName: firstName, lastName: lastName)
                        phoneContacts.append(contact)
                    })
                } catch {
                    
                }
            }
            
        }
        
        
        var contactArrayToSendUpdate = [AddContactsRequestModel]()
        if let cachePhoneContacts = Chat.cacheDB.retrievePhoneContacts() {
            for contact in phoneContacts {
                var findContactOnPhoneBookCache = false
                for cacheContact in cachePhoneContacts {
                    // if there is some number that is already exist on the both phone contact and phoneBookCache, check if there is any update, update the contact
                    if contact.cellphoneNumber == cacheContact.cellphoneNumber {
                        findContactOnPhoneBookCache = true
                        if cacheContact.email != contact.email {
                            contactArrayToSendUpdate.append(contact)
                            Chat.cacheDB.savePhoneBookContact(contact: contact)
                            
                        } else if cacheContact.firstName != contact.firstName {
                            contactArrayToSendUpdate.append(contact)
                            Chat.cacheDB.savePhoneBookContact(contact: contact)
                            
                        } else if cacheContact.lastName != contact.lastName {
                            contactArrayToSendUpdate.append(contact)
                            Chat.cacheDB.savePhoneBookContact(contact: contact)
                        }
                        
                    }
                }
                
                if (!findContactOnPhoneBookCache) {
                    contactArrayToSendUpdate.append(contact)
                    Chat.cacheDB.savePhoneBookContact(contact: contact)
                }
                
            }
        } else {
            // if there is no data on phoneBookCache, add all contacts from phone and save them on cache
            for contact in phoneContacts {
                contactArrayToSendUpdate.append(contact)
                Chat.cacheDB.savePhoneBookContact(contact: contact)
            }
        }
        
        
        for item in contactArrayToSendUpdate {
            addContact(addContactsInput: item, uniqueId: { _ in
            }) { (myResponse) in
                completion(myResponse)
            }
        }
        
        
        
    }
    
    
    // MARK: - Thread Management
    
    /*
     GetThreads:
     By calling this function, a request of type 14 (GET_THREADS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - count:        how many thread do you want to get with this request.           (Int)       -optional-  , if you don't set it, it would have default value of 50
     - offset:       offset of the contact number that start to count to show.       (Int)       -optional-  , if you don't set it, it would have default value of 0
     - name:         if you want to search on your contact, put it here.             (String)    -optional-  ,
     - new:
     - threadIds:    this parameter gets an array of threadId to fileter the result. ([Int])     -optional-  ,
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (GetThreadsModel)
     3- cacheResponse:  there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     */
    public func getThreads(getThreadsInput: GetThreadsRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias,
                           cacheResponse:   @escaping (GetThreadsModel) -> ()) {
        log.verbose("Try to request to get threads with this parameters: \n \(getThreadsInput)", context: "Chat")
        
        //        var threadIdArr: [Int]?
        
        var content: JSON = [:]
        
        content["count"]    = JSON(getThreadsInput.count ?? 50)
        content["offset"]    = JSON(getThreadsInput.offset ?? 0)
        
        if let name = getThreadsInput.name {
            content["name"] = JSON(name)
        }
        
        if let new = getThreadsInput.new {
            content["new"] = JSON(new)
        }
        
        if let threadIds = getThreadsInput.threadIds {
            content["threadIds"] = JSON(threadIds)
            //            threadIdArr = threadIds
        }
        
        if let coreUserId = getThreadsInput.coreUserId {
            content["coreUserId"] = JSON(coreUserId)
        }
        
        if let metadataCriteria = getThreadsInput.metadataCriteria {
            content["metadataCriteria"] = JSON(metadataCriteria)
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_THREADS.rawValue,
                                       "content": content,
                                       "typeCode": getThreadsInput.typeCode ?? generalTypeCode]
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetThreadsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getThreadUniqueId) in
            uniqueId(getThreadUniqueId)
        }
        threadsCallbackToUser = completion
        
        
        // if cache is enabled by user, it will return cache result to the user
        if enableCache {
            if let cacheThreads = Chat.cacheDB.retrieveThreads(ascending:   true,
                                                               count:       getThreadsInput.count ?? 50,
                                                               name:        getThreadsInput.name,
                                                               offset:      getThreadsInput.offset ?? 0,
                                                               threadIds:   getThreadsInput.threadIds,
                                                               timeStamp:   cacheTimeStamp) {
                cacheResponse(cacheThreads)
            }
        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'GetThreadsRequestModel' to get the parameters, it'll use JSON
    public func getThreads(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get threads with this parameters: \n \(params ?? "params is empty!")", context: "Chat")
        
        var myTypeCode: String = generalTypeCode
        
        var content: JSON = ["count": 50, "offset": 0]
        
        if let parameters = params {
            if let count = parameters["count"].int {
                if count > 0 {
                    content["count"] = JSON(count)
                }
            }
            
            if let offset = parameters["offset"].int {
                if offset > 0 {
                    content["offset"] = JSON(offset)
                }
            }
            
            if let name = parameters["name"].string {
                content["name"] = JSON(name)
            }
            
            if let new = parameters["new"].bool {
                content["new"] = JSON(new)
            }
            
            if let threadIds = parameters["threadIds"].arrayObject {
                content["threadIds"] = JSON(threadIds)
            }
            
            if let typeCode = parameters["typeCode"].string {
                myTypeCode = typeCode
            }
            
            if let metadataCriteria = parameters["metadataCriteria"].string {
                content["metadataCriteria"] = JSON(metadataCriteria)
            } else if (parameters["metadataCriteria"] != JSON.null) {
                content["metadataCriteria"] = parameters["metadataCriteria"]
            }
            
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_THREADS.rawValue,
                                       "content": content,
                                       "typeCode": myTypeCode]
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetThreadsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getThreadUniqueId) in
            uniqueId(getThreadUniqueId)
        }
        threadsCallbackToUser = completion
    }
    
    
    /*
     GetHistory:
     get messages in a thread
     
     By calling this function, a request of type 15 (GET_HISTORY) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:         the Thread that you want to get the history from it.            (Int)
     - count:            how many thread do you want to get with this request.           (Int)       -optional-  , if you don't set it, it would have default value of 50
     - offset:           offset of the contact number that start to count to show.       (Int)       -optional-  , if you don't set it, it would have default value of 0
     - firstMessageId:                       (Int)    -optional-  ,
     - lastMessageId:                        (Int)    -optional-  ,
     - order:            order of showiing the history should be Ascending or descending.    (String)    -optional-  ,
     - query:
     - metadataCriteria:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (GetHistoryModel)
     3- cacheResponse:  there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     */
    public func getHistory(getHistoryInput:         GetHistoryRequestModel,
                           uniqueId:                @escaping (String) -> (),
                           completion:              @escaping callbackTypeAlias,
                           cacheResponse:           @escaping (GetHistoryModel) -> (),
                           textMessagesNotSent:     @escaping ([QueueOfWaitTextMessagesModel]) -> (),
                           editMessagesNotSent:     @escaping ([QueueOfWaitEditMessagesModel]) -> (),
                           forwardMessagesNotSent:  @escaping ([QueueOfWaitForwardMessagesModel]) -> (),
                           fileMessagesNotSent:     @escaping ([QueueOfWaitFileMessagesModel]) -> (),
                           uploadImageNotSent:      @escaping ([QueueOfWaitUploadImagesModel]) -> (),
                           uploadFileNotSent:       @escaping ([QueueOfWaitUploadFilesModel]) -> ()) {
        log.verbose("Try to request to get history with this parameters: \n \(getHistoryInput)", context: "Chat")
        
        var content: JSON = [:]
        content["count"] = JSON(getHistoryInput.count ?? 50)
        content["offset"] = JSON(getHistoryInput.offset ?? 0)
        
        if let firstMessageId = getHistoryInput.firstMessageId {
            content["firstMessageId"] = JSON(firstMessageId)
        }
        
        if let lastMessageId = getHistoryInput.lastMessageId {
            content["lastMessageId"] = JSON(lastMessageId)
        }
        
        if let from = getHistoryInput.fromTime {
            if let first13Digits = Int(exactly: (from / 1000000)) {
                content["fromTime"] = JSON(first13Digits)
                content["fromTimeNanos"] = JSON(Int(exactly: (from - UInt(first13Digits * 1000000)))!)
            }
        }
        
        if let to = getHistoryInput.toTime {
            if let first13Digits = Int(exactly: (to / 1000000)) {
                content["toTime"] = JSON(first13Digits)
                content["toTimeNanos"] = JSON(Int(exactly: (to - UInt(first13Digits * 1000000)))!)
            }
        }
        
        
        //        var asscenging = true
        if let order = getHistoryInput.order {
            content["order"] = JSON(order)
            //            if (order == "DESC") {
            //                asscenging = false
            //            }
        }
        
        if let query = getHistoryInput.query {
            content["query"] = JSON(query)
        }
        
        if let metadataCriteria = getHistoryInput.metadataCriteria {
            content["metadataCriteria"] = JSON(metadataCriteria)
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_HISTORY.rawValue,
                                       "content": content,
                                       "typeCode": getHistoryInput.typeCode ?? generalTypeCode,
                                       "subjectId": getHistoryInput.threadId]
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetHistoryCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getHistoryUniqueId) in
            uniqueId(getHistoryUniqueId)
        }
        historyCallbackToUser = completion
        
        
        
        // if cache is enabled by user, first return cache result to the user
        if enableCache {
            
            if let textMessages = Chat.cacheDB.retrieveWaitTextMessages(threadId: getHistoryInput.threadId) {
                textMessagesNotSent(textMessages)
            }
            if let editMessages = Chat.cacheDB.retrieveWaitEditMessages(threadId: getHistoryInput.threadId) {
                editMessagesNotSent(editMessages)
            }
            if let forwardMessages = Chat.cacheDB.retrieveWaitForwardMessages(threadId: getHistoryInput.threadId) {
                forwardMessagesNotSent(forwardMessages)
            }
            if let fileMessages = Chat.cacheDB.retrieveWaitFileMessages(threadId: getHistoryInput.threadId) {
                fileMessagesNotSent(fileMessages)
            }
            if let uploadImages = Chat.cacheDB.retrieveWaitUploadImages(threadId: getHistoryInput.threadId) {
                uploadImageNotSent(uploadImages)
            }
            if let uploadFiles = Chat.cacheDB.retrieveWaitUploadFiles(threadId: getHistoryInput.threadId) {
                uploadFileNotSent(uploadFiles)
            }
            
            if let cacheHistoryResult = Chat.cacheDB.retrieveMessageHistory(count:          getHistoryInput.count ?? 50,
                                                                            firstMessageId: getHistoryInput.firstMessageId,
                                                                            fromTime:       getHistoryInput.fromTime,
                                                                            lastMessageId:  getHistoryInput.lastMessageId,
                                                                            messageId:      getHistoryInput.messageId,
                                                                            offset:         getHistoryInput.offset ?? 0,
                                                                            order:          getHistoryInput.order,
                                                                            query:          getHistoryInput.query,
                                                                            threadId:       getHistoryInput.threadId,
                                                                            toTime:         getHistoryInput.toTime,
                                                                            uniqueId:       getHistoryInput.uniqueId) {
                cacheResponse(cacheHistoryResult)
            }
        }
        
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'GetHistoryRequestModel' to get the parameters, it'll use JSON
    public func getHistory(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get history with this parameters: \n \(params)", context: "Chat")
        
        var content: JSON = ["count": 50, "offset": 0]
        if let count = params["count"].int {
            if count > 0 {
                content["count"] = JSON(count)
            }
        }
        
        if let offset = params["offset"].int {
            if offset > 0 {
                content["offset"] = JSON(offset)
            }
        }
        
        if let firstMessageId = params["firstMessageId"].int {
            if firstMessageId > 0 {
                content["firstMessageId"] = JSON(firstMessageId)
            }
        }
        
        if let lastMessageId = params["lastMessageId"].int {
            if lastMessageId > 0 {
                content["lastMessageId"] = JSON(lastMessageId)
            }
        }
        
        if let order = params["order"].string {
            content["order"] = JSON(order)
        }
        
        if let query = params["query"].string {
            content["query"] = JSON(query)
        }
        
        if let metadataCriteria = params["metadataCriteria"].string {
            content["metadataCriteria"] = JSON(metadataCriteria)
        } else if (params["metadataCriteria"] != JSON.null) {
            content["metadataCriteria"] = params["metadataCriteria"]
        }
        
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_HISTORY.rawValue,
                                       "content": content,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "subjectId": params["threadId"].intValue]
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetHistoryCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getHistoryUniqueId) in
            uniqueId(getHistoryUniqueId)
        }
        historyCallbackToUser = completion
    }
    
    
    
    /*
     ClearHistory
     
     */
    public func clearHistory(clearHistoryInput: ClearHistoryRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias,
                             cacheResponse:     @escaping callbackTypeAlias) {
        log.verbose("Try to request to create clear history with this parameters: \n \(clearHistoryInput)", context: "Chat")
        
        var content: JSON = [:]
        
//        content["subjectId"] = JSON(clearHistoryInput.threadId)
        
        if let requestUniqueId = clearHistoryInput.uniqueId {
            content["uniqueId"] = JSON(requestUniqueId)
        }
        
        let sendMessageClearHistoryParams: JSON = ["chatMessageVOType": chatMessageVOTypes.CLEAR_HISTORY.rawValue,
                                                   "content": content,
                                                   "subjectId": clearHistoryInput.threadId]
        
        sendMessageWithCallback(params: sendMessageClearHistoryParams,
                                callback: ClearHistoryCallback(parameters: sendMessageClearHistoryParams),
                                sentCallback:   nil,
                                deliverCallback: nil,
                                seenCallback:   nil) { (clearHistoryUniqueId) in
                                    uniqueId(clearHistoryUniqueId)
        }
        
        clearHistoryCallbackToUser = completion
    }
    
    
    /*
     CreateThread:
     create a thread with somebody
     
     By calling this function, a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - title:       give a title to the thread that you are going to create.    (String)
     - type:        type of the thread that you are creating.                   (String)
     - invitees:    this is also a JSON file that contains: "id" and "idType"   (Invitee)
     - uniqueId:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (CreateThreadModel)
     */
    public func createThread(createThreadInput: CreateThreadRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        log.verbose("Try to request to create thread participants with this parameters: \n \(createThreadInput)", context: "Chat")
        
        var content: JSON = [:]
        
        content["title"] = JSON(createThreadInput.title)
        var inviteees = [JSON]()
        for item in createThreadInput.invitees {
            inviteees.append(item.formatToJSON())
        }
        content["invitees"] = JSON(inviteees)
        
        if let image = createThreadInput.image {
            content["image"] = JSON(image)
        }
        
        if let metaData = createThreadInput.metadata {
            content["metadata"] = JSON(metaData)
        }
        
        if let description = createThreadInput.description {
            content["description"] = JSON(description)
        }
        
        if let type = createThreadInput.type {
            var theType: Int = 0
            switch type {
            case ThreadTypes.NORMAL.rawValue:         theType = 0
            case ThreadTypes.OWNER_GROUP.rawValue:    theType = 1
            case ThreadTypes.PUBLIC_GROUP.rawValue:   theType = 2
            case ThreadTypes.CHANNEL_GROUP.rawValue:  theType = 4
            case ThreadTypes.CHANNEL.rawValue:        theType = 8
            default:
//                print("not valid thread type on create thread")
                log.error("not valid thread type on create thread", context: "Chat")
            }
            content["type"] = JSON(theType)
        }
        
        let sendMessageCreateThreadParams: JSON = ["chatMessageVOType": chatMessageVOTypes.CREATE_THREAD.rawValue,
                                                   "content": content]
        sendMessageWithCallback(params: sendMessageCreateThreadParams, callback: CreateThreadCallback(parameters: sendMessageCreateThreadParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (createThreadUniqueId) in
            uniqueId(createThreadUniqueId)
        }
        
        createThreadCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'CreateThreadRequestModel' to get the parameters, it'll use JSON
    public func createThread(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to create thread participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        var content: JSON = [:]
        
        if let parameters = params {
            
            if let title = parameters["title"].string {
                content.appendIfDictionary(key: "title", json: JSON(title))
            }
            
            if let type = parameters["type"].string {
                var theType: Int = 0
                switch type {
                case ThreadTypes.NORMAL.rawValue:         theType = 0
                case ThreadTypes.OWNER_GROUP.rawValue:    theType = 1
                case ThreadTypes.PUBLIC_GROUP.rawValue:   theType = 2
                case ThreadTypes.CHANNEL_GROUP.rawValue:  theType = 4
                case ThreadTypes.CHANNEL.rawValue:        theType = 8
                default:
//                    print("not valid thread type on create thread")
                    log.error("not valid thread type on create thread", context: "Chat")
                }
                content.appendIfDictionary(key: "type", json: JSON(theType))
            }
            
            if let title = parameters["title"].string {
                content.appendIfDictionary(key: "title", json: JSON(title))
            }
            
            if let invitees = parameters["invitees"].array {
                content.appendIfDictionary(key: "invitees", json: JSON(invitees))
            }
        }
        
        let sendMessageCreateThreadParams: JSON = ["chatMessageVOType": chatMessageVOTypes.CREATE_THREAD.rawValue,
                                                   "content": content]
        sendMessageWithCallback(params: sendMessageCreateThreadParams, callback: CreateThreadCallback(parameters: sendMessageCreateThreadParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (createThreadUniqueId) in
            uniqueId(createThreadUniqueId)
        }
        
        createThreadCallbackToUser = completion
        
    }
    
    
    /*
     CreateThreadAndSendMessage:
     create a thread with somebody and simultaneously send a message on this thread.
     
     By calling this function, a request of type 1 (CREATE_THREAD) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadTitle:       give a title to the thread that you are going to create.    (String)
     - threadType:        type of the thread that you are creating.                   (String)
     - threadInvitees:    this is also a JSON file that contains: "id" and "idType".  (Invitee)
     - uniqueId:
     - messageContent:       content of the message (the text Message).                      (String)
     - messageMetaDataId:    id property of the methadata of the message.                (Int)
     - messageMetaDataType:  type property of the methadata of the message.              (String)
     - messageMetaDataOwner: owner property of the methadata of the message.             (String)
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (CreateThreadModel)
     3- onSent:
     4- onDelivere:
     5- onSeen:
     */
    public func createThreadWithMessage(creatThreadWithMessageInput: CreateThreadWithMessageRequestModel,
                                       uniqueId:                    @escaping (String) -> (),
                                       completion:                  @escaping callbackTypeAlias,
                                       onSent:                      @escaping callbackTypeAlias,
                                       onDelivere:                  @escaping callbackTypeAlias,
                                       onSeen:                      @escaping callbackTypeAlias) {
        log.verbose("Try to request to create thread and Send Message participants with this parameters: \n \(creatThreadWithMessageInput)", context: "Chat")
        
        let myUniqueId = generateUUID()

        var metadata: JSON = [:]
        if let msgMetadata = creatThreadWithMessageInput.messageMetaDataId {
            metadata["id"] = JSON(msgMetadata)
        }
        if let msgMetaType = creatThreadWithMessageInput.messageMetaDataType {
            metadata["type"] = JSON(msgMetaType)
        }
        if let msgMetaOwner = creatThreadWithMessageInput.messageMetaDataOwner {
            metadata["owner"]   = JSON(msgMetaOwner)
        }
        
        print("\n\n\n\n***********\n metadata = \n\(metadata)\n*************\n\n\n\n")
        
        var messageContentParams: JSON = [:]
        messageContentParams["content"]     = JSON(creatThreadWithMessageInput.messageContent)
        messageContentParams["uniqueId"]    = JSON(myUniqueId)
        messageContentParams["metaData"]    = metadata
        
        print("\n\n\n\n***********\n messageContentParams = \n\(messageContentParams)\n*************\n\n\n\n")
        
        var myContent: JSON = [:]
        
        myContent["message"]    = JSON(messageContentParams)
        myContent["uniqueId"]   = JSON(myUniqueId)
        myContent["title"]      = JSON(creatThreadWithMessageInput.threadTitle)
        var inviteees = [JSON]()
        for item in creatThreadWithMessageInput.threadInvitees {
            inviteees.append(item.formatToJSON())
        }
        myContent["invitees"] = JSON(inviteees)
        
        if let image = creatThreadWithMessageInput.threadImage {
            myContent["image"] = JSON(image)
        }
        if let metaData = creatThreadWithMessageInput.threadMetadata {
            myContent["metadata"] = JSON(metaData)
        }
        if let description = creatThreadWithMessageInput.threadDescription {
            myContent["description"] = JSON(description)
        }

        if let type = creatThreadWithMessageInput.threadType {
            var theType: Int = 0
            switch type {
            case ThreadTypes.NORMAL.rawValue:         theType = 0
            case ThreadTypes.OWNER_GROUP.rawValue:    theType = 1
            case ThreadTypes.PUBLIC_GROUP.rawValue:   theType = 2
            case ThreadTypes.CHANNEL_GROUP.rawValue:  theType = 4
            case ThreadTypes.CHANNEL.rawValue:        theType = 8
            default:
//                print("not valid thread type on create thread")
                log.error("not valid thread type on create thread", context: "Chat")
            }
            myContent["type"] = JSON(theType)
        }
        
        print("\n\n\n\n***********\n myContent = \n\(myContent)\n*************\n\n\n\n")
//        let myUniqueId = generateUUID()
//
//        var message: JSON = ["text": creatThreadWithMessageInput.messageContentText]
//
//        if let mui = creatThreadWithMessageInput.messageUniqueId {
//            message["uniqueId"] = JSON("\(mui)")
//        }
//        if let mt = creatThreadWithMessageInput.messageType {
//            message["type"] = JSON(mt)
//        }
//        if let mr = creatThreadWithMessageInput.messageRepliedTo {
//            message["repliedTo"] = JSON(mr)
//        }
//        if let mmt = creatThreadWithMessageInput.messageMetaData {
//            message["metadata"] = JSON("\(mmt)")
//        }
//        if let msmt = creatThreadWithMessageInput.messageSystemMetadata {
//            message["systemMetadata"] = JSON("\(msmt)")
//        }
//        if let mfi = creatThreadWithMessageInput.messageForwardMessageIds {
//            message["forwardedMessageIds"] = JSON(mfi)
//            var uIds: [String] = []
//            for _ in mfi {
//                uIds.append(generateUUID())
//            }
//            message["forwardedUniqueIds"] = JSON(uIds)
//        }
//
//
//        var content: JSON = ["message": message]
//        content["uniqueId"] = JSON(myUniqueId)
//        content["title"] = JSON(creatThreadWithMessageInput.threadTitle)
//        content["invitees"] = JSON(creatThreadWithMessageInput.threadInvitees)
//
//        if let image = creatThreadWithMessageInput.threadImage {
//            content["image"] = JSON(image)
//        }
//        if let metaData = creatThreadWithMessageInput.threadMetadata {
//            content["metadata"] = JSON(metaData)
//        }
//        if let description = creatThreadWithMessageInput.threadDescription {
//            content["description"] = JSON(description)
//        }
//
//        if let type = creatThreadWithMessageInput.threadType {
//            var theType: Int = 0
//            switch type {
//            case ThreadTypes.NORMAL.rawValue:         theType = 0
//            case ThreadTypes.OWNER_GROUP.rawValue:    theType = 1
//            case ThreadTypes.PUBLIC_GROUP.rawValue:   theType = 2
//            case ThreadTypes.CHANNEL_GROUP.rawValue:  theType = 4
//            case ThreadTypes.CHANNEL.rawValue:        theType = 8
//            default: log.error("not valid thread type on create thread", context: "Chat")
//            }
//            content["type"] = JSON(theType)
//        }
        
        let sendMessageCreateThreadParams: JSON = ["chatMessageVOType": chatMessageVOTypes.CREATE_THREAD.rawValue,
                                                   "content": myContent,
                                                   "uniqueId": myUniqueId]
        
//        sendMessageWithCallback(params: sendMessageCreateThreadParams,
//                                callback: CreateThreadCallback(parameters: sendMessageCreateThreadParams),
//                                sentCallback: SendMessageCallbacks(parameters: content),
//                                deliverCallback: SendMessageCallbacks(parameters: content),
//                                seenCallback: SendMessageCallbacks(parameters: content)) { (theUniqueId) in
//                                    uniqueId(theUniqueId)
//        }
        
        
        messageContentParams["isCreateThreadAndSendMessage"] = JSON(true)
        sendMessageWithCallback(params: sendMessageCreateThreadParams, callback: CreateThreadCallback(parameters: sendMessageCreateThreadParams),
                                sentCallback: SendMessageCallbacks(parameters: messageContentParams),
                                deliverCallback: SendMessageCallbacks(parameters: messageContentParams),
                                seenCallback: SendMessageCallbacks(parameters: messageContentParams)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        createThreadCallbackToUser = completion
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'CreateThreadWithMessageRequestModel' to get the parameters, it'll use JSON
    public func createThreadWithMessage(params: JSON?, sendMessageParams: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias, onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to request to create thread and Send Message participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        let myUniqueId = generateUUID()
        
        var messageContentParams: JSON = sendMessageParams
        messageContentParams["uniqueId"] = JSON(myUniqueId)
        
        var content: JSON = ["message": messageContentParams]
        
        if let parameters = params {
            
            content["uniqueId"] = JSON(myUniqueId)
            
            if let title = parameters["title"].string {
                content.appendIfDictionary(key: "title", json: JSON(title))
            }
            
            if let type = parameters["type"].string {
                var theType: Int = 0
                switch type {
                case ThreadTypes.NORMAL.rawValue: theType = 0
                case ThreadTypes.OWNER_GROUP.rawValue: theType = 1
                case ThreadTypes.PUBLIC_GROUP.rawValue: theType = 2
                case ThreadTypes.CHANNEL_GROUP.rawValue: theType = 4
                case ThreadTypes.CHANNEL.rawValue: theType = 8
                default:
//                    print("not valid thread type on create thread")
                    log.error("not valid thread type on create thread", context: "Chat")
                }
                content.appendIfDictionary(key: "type", json: JSON(theType))
            }
            
            if let title = parameters["title"].string {
                content.appendIfDictionary(key: "title", json: JSON(title))
            }
            
            if let invitees = parameters["invitees"].array {
                content.appendIfDictionary(key: "invitees", json: JSON(invitees))
            }
        }
        let sendMessageCreateThreadParams: JSON = ["chatMessageVOType": chatMessageVOTypes.CREATE_THREAD.rawValue,
                                                   "content": content,
                                                   "uniqueId": myUniqueId]
        
        sendMessageWithCallback(params: sendMessageCreateThreadParams, callback: CreateThreadCallback(parameters: sendMessageCreateThreadParams), sentCallback: SendMessageCallbacks(parameters: sendMessageCreateThreadParams), deliverCallback: SendMessageCallbacks(parameters: sendMessageCreateThreadParams), seenCallback: SendMessageCallbacks(parameters: sendMessageCreateThreadParams)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        createThreadCallbackToUser = completion
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
    }
    
    // NOTE: This method will be deprecate
    // implement creating a thread and sending a message with it, handeled by this SDK (not server!)
    public func createThreadAndSendMessage(params: JSON?, sendMessageParams: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias, onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to request to create thread and Send Message participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        var myUniqueId: String = ""
        createThread(params: params, uniqueId: { (createThreadUniqueId) in
            myUniqueId = createThreadUniqueId
            uniqueId(createThreadUniqueId)
        }) { (myCreateThreadResponse) in
            
            let myResponseModel: CreateThreadModel = myCreateThreadResponse as! CreateThreadModel
            let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
            
            var sendParams: JSON = sendMessageParams
            sendParams["uniqueId"] = JSON(myUniqueId)
            if let theId = myResponseJSON["result"]["thread"]["id"].int {
                sendParams["subjectId"] = JSON(theId)
            }
            
            self.sendTextMessage(params: sendParams, uniqueId: { _ in }, onSent: { (isSent) in
                onSent(isSent)
            }, onDelivere: { (isDeliver) in
                onDelivere(isDeliver)
            }, onSeen: { (isSeen) in
                onSeen(isSeen)
            })
            
        }
        
    }
    
    
    /*
     MuteThread:
     mute a thread
     
     By calling this function, a request of type 19 (MUTE_THREAD) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:   id of the thread that you want to mute it.    (Int)
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (??)
     */
    public func muteThread(muteThreadInput: MuteAndUnmuteThreadRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        log.verbose("Try to request to mute threads with this parameters: \n \(muteThreadInput)", context: "Chat")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MUTE_THREAD.rawValue,
                                       "typeCode": muteThreadInput.typeCode ?? generalTypeCode,
                                       "subjectId": muteThreadInput.subjectId]
        
        sendMessageWithCallback(params: sendMessageParams, callback: MuteThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        muteThreadCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'MuteAndUnmuteThreadRequestModel' to get the parameters, it'll use JSON
    public func muteThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to mute threads with this parameters: \n \(params)", context: "Chat")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MUTE_THREAD.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "subjectId": params["subjectId"].intValue]
        
        sendMessageWithCallback(params: sendMessageParams, callback: MuteThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        muteThreadCallbackToUser = completion
    }
    
    
    /*
     UnmuteThread:
     mute a thread
     
     By calling this function, a request of type 20 (UNMUTE_THREAD) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:   id of the thread that you want to mute it.    (Int)
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (??)
     */
    public func unmuteThread(unmuteThreadInput: MuteAndUnmuteThreadRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        log.verbose("Try to request to unmute threads with this parameters: \n \(unmuteThreadInput)", context: "Chat")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UNMUTE_THREAD.rawValue,
                                       "typeCode": unmuteThreadInput.typeCode ?? generalTypeCode,
                                       "subjectId": unmuteThreadInput.subjectId]
        
        sendMessageWithCallback(params: sendMessageParams, callback: UnmuteThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        unmuteThreadCallbackToUser = completion
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'MuteAndUnmuteThreadRequestModel' to get the parameters, it'll use JSON
    public func unmuteThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to unmute threads with this parameters: \n \(params)", context: "Chat")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UNMUTE_THREAD.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "subjectId": params["subjectId"].intValue]
        
        sendMessageWithCallback(params: sendMessageParams, callback: UnmuteThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        unmuteThreadCallbackToUser = completion
    }
    
    
    /*
     GetThreadParticipants:
     get all participants in a specific thread.
     
     By calling this function, a request of type 27 (THREAD_PARTICIPANTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:    id of the thread that you want to mute it.    (Int)
     - count:
     - offset:
     - firstMessageId:
     - lastMessageId:
     - name:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (GetThreadParticipantsModel)
     3- cacheResponse:  there is another response that comes from CacheDB to the user, if user has set 'enableCache' vaiable to be true
     */
    public func getThreadParticipants(getThreadParticipantsInput:   GetThreadParticipantsRequestModel,
                                      uniqueId:                     @escaping (String) -> (),
                                      completion:                   @escaping callbackTypeAlias,
                                      cacheResponse:                @escaping (GetThreadParticipantsModel) -> ()) {
        log.verbose("Try to request to get thread participants with this parameters: \n \(getThreadParticipantsInput)", context: "Chat")
        
        var content: JSON = [:]
        content["threadId"] = JSON(getThreadParticipantsInput.threadId)
        content["count"]    = JSON(getThreadParticipantsInput.count ?? getHistoryCount)
        content["offset"]   = JSON(getThreadParticipantsInput.offset ?? 0)
        
        if let firstMessageId = getThreadParticipantsInput.firstMessageId {
            content["firstMessageId"]   = JSON(firstMessageId)
        }
        
        if let lastMessageId = getThreadParticipantsInput.lastMessageId {
            content["lastMessageId"]   = JSON(lastMessageId)
        }
        
        if let name = getThreadParticipantsInput.name {
            content["name"]   = JSON(name)
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.THREAD_PARTICIPANTS.rawValue,
                                       "typeCode": getThreadParticipantsInput.typeCode ?? generalTypeCode,
                                       "content": content,
                                       "subjectId": getThreadParticipantsInput.threadId]
        sendMessageWithCallback(params: sendMessageParams, callback: GetThreadParticipantsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getParticipantsUniqueId) in
            uniqueId(getParticipantsUniqueId)
        }
        threadParticipantsCallbackToUser = completion
        
        
        // if cache is enabled by user, it will return cache result to the user
        if enableCache {
            if let cacheThreadParticipants = Chat.cacheDB.retrieveThreadParticipants(ascending: true,
                                                                                     count:     content["count"].intValue,
                                                                                     offset:    content["offset"].intValue,
                                                                                     threadId:  getThreadParticipantsInput.threadId,
                                                                                     timeStamp: cacheTimeStamp) {
                cacheResponse(cacheThreadParticipants)
            }
        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'GetThreadParticipantsRequestModel' to get the parameters, it'll use JSON
    public func getThreadParticipants(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get thread participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        var myTypeCode = generalTypeCode
        var content: JSON = ["count": getHistoryCount, "offset": 0]
        var subjectId: Int = 0
        
        if let parameters = params {
            
            if let subId = parameters["threadId"].int {
                subjectId = subId
            }
            
            if let count = parameters["count"].int {
                if count > 0 {
                    content["count"] = JSON(count)
                }
            }
            
            if let offset = parameters["offset"].int {
                if offset > 0 {
                    content["offset"] = JSON(offset)
                }
            }
            
            if let firstMessageId = parameters["firstMessageId"].int {
                if firstMessageId > 0 {
                    content["firstMessageId"] = JSON(firstMessageId)
                }
            }
            
            if let lastMessageId = parameters["lastMessageId"].int {
                if lastMessageId > 0 {
                    content["lastMessageId"] = JSON(lastMessageId)
                }
            }
            
            if let name = parameters["name"].string {
                content["name"] = JSON(name)
            }
            
            if let typeCode = parameters["typeCode"].string {
                myTypeCode = typeCode
            }
            
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.THREAD_PARTICIPANTS.rawValue,
                                       "typeCode": myTypeCode,
                                       "content": content,
                                       "subjectId": subjectId]
        sendMessageWithCallback(params: sendMessageParams, callback: GetThreadParticipantsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getParticipantsUniqueId) in
            uniqueId(getParticipantsUniqueId)
        }
        threadParticipantsCallbackToUser = completion
    }
    
    
    /*
     AddParticipants:
     add participant to a specific thread.
     
     By calling this function, a request of type 11 (ADD_PARTICIPANT) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:     id of the thread that you want to add somebody to it.    (Int)
     - contacts:     array of contact ids to add them to this thread
     - uniqueId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (AddParticipantModel)
     */
    public func addParticipants(addParticipantsInput:   AddParticipantsRequestModel,
                                uniqueId:               @escaping (String) -> (),
                                completion:             @escaping callbackTypeAlias) {
        log.verbose("Try to request to add participants with this parameters: \n \(addParticipantsInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.ADD_PARTICIPANT.rawValue]
        sendMessageParams["subjectId"] = JSON(addParticipantsInput.threadId)
        sendMessageParams["content"] = JSON(addParticipantsInput.contacts)
        sendMessageParams["typeCode"] = JSON(addParticipantsInput.typeCode ?? generalTypeCode)
        
        if let uniqueId = addParticipantsInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: AddParticipantsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (addParticipantsUniqueId) in
            uniqueId(addParticipantsUniqueId)
        }
        addParticipantsCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'AddParticipantsRequestModel' to get the parameters, it'll use JSON
    public func addParticipants(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to add participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        /*
         * + AddParticipantsRequest   {object}
         *    - subjectId             {long}
         *    + content               {list} List of CONTACT IDs
         *       -id                  {long}
         *    - uniqueId              {string}
         */
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.ADD_PARTICIPANT.rawValue]
        
        if let parameters = params {
            
            if let threadId = parameters["threadId"].int {
                if (threadId > 0) {
                    sendMessageParams["subjectId"] = JSON(threadId)
                }
            }
            
            if let contacts = parameters["contacts"].arrayObject {
                sendMessageParams["content"] = JSON(contacts)
            }
            
            if let typeCode = parameters["typeCode"].string {
                sendMessageParams["typeCode"] = JSON(typeCode)
            } else {
                sendMessageParams["typeCode"] = JSON(generalTypeCode)
            }
            
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: AddParticipantsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (addParticipantsUniqueId) in
            uniqueId(addParticipantsUniqueId)
        }
        addParticipantsCallbackToUser = completion
    }
    
    
    /*
     RemoveParticipants:
     remove participants from a specific thread.
     
     By calling this function, a request of type 18 (REMOVE_PARTICIPANT) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:     id of the thread that you want to remove some participant it.    (Int)
     - content:      array of participants in the thread to remove them.
     - uniqueId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (RemoveParticipantModel)
     */
    public func removeParticipants(removeParticipantsInput: RemoveParticipantsRequestModel,
                                   uniqueId:                @escaping (String) -> (),
                                   completion:              @escaping callbackTypeAlias) {
        log.verbose("Try to request to remove participants with this parameters: \n \(removeParticipantsInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.REMOVE_PARTICIPANT.rawValue]
        sendMessageParams["subjectId"] = JSON(removeParticipantsInput.threadId)
        sendMessageParams["content"] = JSON(removeParticipantsInput.content)
        sendMessageParams["typeCode"] = JSON(removeParticipantsInput.typeCode ?? generalTypeCode)
        
        if let uniqueId = removeParticipantsInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: RemoveParticipantsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (removeParticipantsUniqueId) in
            uniqueId(removeParticipantsUniqueId)
        }
        removeParticipantsCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'RemoveParticipantsRequestModel' to get the parameters, it'll use JSON
    public func removeParticipants(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to remove participants with this parameters: \n \(params ?? "params is empty")", context: "Chat")
        
        /*
         * + RemoveParticipantsRequest    {object}
         *    - subjectId                 {long}
         *    + content                   {list} List of PARTICIPANT IDs from Thread's Participants object
         *       -id                      {long}
         *    - uniqueId                  {string}
         */
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.REMOVE_PARTICIPANT.rawValue]
        
        if let parameters = params {
            
            if let threadId = parameters["threadId"].int {
                if (threadId > 0) {
                    sendMessageParams["subjectId"] = JSON(threadId)
                }
            }
            
            if (parameters["participants"] != JSON.null) {
                sendMessageParams["content"] = JSON(parameters["participants"])
            }
            
            if let typeCode = parameters["typeCode"].string {
                sendMessageParams["typeCode"] = JSON(typeCode)
            } else {
                sendMessageParams["typeCode"] = JSON(generalTypeCode)
            }
            
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: RemoveParticipantsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (removeParticipantsUniqueId) in
            uniqueId(removeParticipantsUniqueId)
        }
        removeParticipantsCallbackToUser = completion
    }
    
    
    /*
     LeaveThread:
     leave from a specific thread.
     
     By calling this function, a request of type 9 (LEAVE_THREAD) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:     id of the thread that you want to remove some participant it.    (Int)
     - content:      array of participants in the thread to remove them.
     - uniqueId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:  it will returns the response that comes from server to this request.    (CreateThreadModel)
     */
    public func leaveThread(leaveThreadInput:   LeaveThreadRequestModel,
                            uniqueId:           @escaping (String) -> (),
                            completion:         @escaping callbackTypeAlias) {
        log.verbose("Try to request to leave thread with this parameters: \n \(leaveThreadInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.LEAVE_THREAD.rawValue,
                                       "typeCode": leaveThreadInput.typeCode ?? generalTypeCode,
                                       "subjectId": leaveThreadInput.threadId]
        
        if let uniqueId = leaveThreadInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: LeaveThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (leaveThreadUniqueId) in
            uniqueId(leaveThreadUniqueId)
        }
        leaveThreadCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'LeaveThreadRequestModel' to get the parameters, it'll use JSON
    public func leaveThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to leave thread with this parameters: \n \(params)", context: "Chat")
        
        /**
         * + LeaveThreadRequest    {object}
         *    - subjectId          {long}
         *    - uniqueId           {string}
         */
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.LEAVE_THREAD.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode]
        
        if let subjectId = params["threadId"].int {
            sendMessageParams["subjectId"] = JSON(subjectId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: LeaveThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (leaveThreadUniqueId) in
            uniqueId(leaveThreadUniqueId)
        }
        leaveThreadCallbackToUser = completion
    }
    
    
    // MARK: - Message Management
    
    /*
     it's all about this 3 characters: 'space' , '\n', '\t'
     this function will put some freak characters instead of these 3 characters (inside the Message text content)
     because later on, the Async will eliminate from all these kind of characters to reduce size of the message that goes through socket,
     on there, we will replace them with the original one;
     so now we don't miss any of these 3 characters on the Test Message, but also can eliminate all extra characters...
     */
    public func makeCustomTextToSend(textMessage: String) -> String {
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
    
    
    /*
     SendTextMessage:
     send a text to somebody.
     
     By calling this function, a request of type 2 (MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - threadId:     id of the thread that you want to remove some participant it.    (Int)
     - content:      array of participants in the thread to remove them.
     - repliedTo:
     - uniqueId:
     - typeCode:
     - systemMetadata:
     - metaData:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- onSent:
     3- onDelivere:
     4- onSeen:
     */
    public func sendTextMessage(sendTextMessageInput:   SendTextMessageRequestModel,
                                uniqueId:               @escaping (String) -> (),
                                onSent:                 @escaping callbackTypeAlias,
                                onDelivere:             @escaping callbackTypeAlias,
                                onSeen:                 @escaping callbackTypeAlias) {
        log.verbose("Try to send Message with this parameters: \n \(sendTextMessageInput)", context: "Chat")
        let tempUniqueId = generateUUID()
        
        // seve this message on the Cache Wait Queue,
        // so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which messages didn't send correctly, and can handle them
//        let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(content:      sendTextMessageInput.content,
//                                                                      metaData:     sendTextMessageInput.metaData,
//                                                                      repliedTo:    sendTextMessageInput.repliedTo,
//                                                                      systemMetadata: sendTextMessageInput.systemMetadata,
//                                                                      threadId:     sendTextMessageInput.threadId,
//                                                                      typeCode:     sendTextMessageInput.typeCode,
//                                                                      uniqueId:     sendTextMessageInput.uniqueId ?? tempUniqueId)
        // this line causes error
//        Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        
        let messageTxtContent = makeCustomTextToSend(textMessage: sendTextMessageInput.content)
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MESSAGE.rawValue,
                                       "pushMsgType": 4,
                                       "subjectId": sendTextMessageInput.threadId,
                                       "content": messageTxtContent,
                                       "typeCode": sendTextMessageInput.typeCode ?? generalTypeCode]
        
        if let repliedTo = sendTextMessageInput.repliedTo {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        
        if let uniqueId = sendTextMessageInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        } else {
            sendMessageParams["uniqueId"] = JSON(tempUniqueId)
        }
        
        if let systemMetadata = sendTextMessageInput.systemMetadata {
            let systemMetadataStr = "\(systemMetadata)"
            sendMessageParams["systemMetadata"] = JSON(systemMetadataStr)
        }
        
        if let metaData = sendTextMessageInput.metaData {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
//        sendMessageParams["subjectId"] = JSON(sendTextMessageInput.threadId)
        
        sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(parameters: sendMessageParams), deliverCallback: SendMessageCallbacks(parameters: sendMessageParams), seenCallback:  SendMessageCallbacks(parameters: sendMessageParams)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'SendTextMessageRequestModel' to get the parameters, it'll use JSON
    public func sendTextMessage(params: JSON, uniqueId: @escaping (String) -> (), onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to send Message with this parameters: \n \(params)", context: "Chat")
        
        let messageTxtContent = makeCustomTextToSend(textMessage: params["content"].stringValue)
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MESSAGE.rawValue,
                                       "pushMsgType": 4,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "content": messageTxtContent]
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["subjectId"] = JSON(threadId)
        }
        if let repliedTo = params["repliedTo"].int {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        
        if let uniqueId = params["uniqueId"].string {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        
        if let systemMetadata = params["systemMetadata"].arrayObject {
            sendMessageParams["systemMetadata"] = JSON(systemMetadata)
        }
        
        if let metaData = params["metaData"].arrayObject {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        
        
        sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(parameters: sendMessageParams), deliverCallback: SendMessageCallbacks(parameters: sendMessageParams), seenCallback:  SendMessageCallbacks(parameters: sendMessageParams)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
    }
    
    
    /*
     EditTextMessage:
     edit text of a messae.
     
     By calling this function, a request of type 28 (EDIT_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:    id of the message that you want to remove some participant it.    (Int)
     - content:      array of participants in the thread to remove them.
     - repliedTo:
     - uniqueId:
     - typeCode:
     - systemMetadata:
     - metaData:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- onSent:
     3- onDelivere:
     4- onSeen:
     */
    public func editMessage(editMessageInput:   EditTextMessageRequestModel,
                            uniqueId:           @escaping (String) -> (),
                            completion:         @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(editMessageInput)", context: "Chat")
        let tempUniqueId = generateUUID()
        
        // seve this message on the Cache Wait Queue,
        // so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which messages didn't send correctly, and can handle them
        let messageObjectToSendToQueue = QueueOfWaitEditMessagesModel(content: editMessageInput.content,
                                                                      metaData: editMessageInput.metaData,
                                                                      repliedTo: editMessageInput.repliedTo,
                                                                      subjectId: editMessageInput.subjectId,
                                                                      typeCode: editMessageInput.typeCode,
                                                                      uniqueId: editMessageInput.uniqueId ?? tempUniqueId)
        Chat.cacheDB.saveEditMessageToWaitQueue(editMessage: messageObjectToSendToQueue)
        
        let messageTxtContent = makeCustomTextToSend(textMessage: editMessageInput.content)
        //        let content: JSON = ["content": messageTxtContent]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.EDIT_MESSAGE.rawValue,
                                       "pushMsgType":       4,
                                       "subjectId":         editMessageInput.subjectId,
                                       "content":           messageTxtContent,
                                       "typeCode":          editMessageInput.typeCode ?? generalTypeCode]
        
        if let repliedTo = editMessageInput.repliedTo {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        
        if let uniqueId = editMessageInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        } else {
            sendMessageParams["uniqueId"] = JSON(tempUniqueId)
        }
        
        if let metaData = editMessageInput.metaData {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: EditMessageCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (editMessageUniqueId) in
            uniqueId(editMessageUniqueId)
        }
        editMessageCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'EditTextMessageRequestModel' to get the parameters, it'll use JSON
    public func editMessage(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(params)", context: "Chat")
        
        let messageTxtContent = makeCustomTextToSend(textMessage: params["content"].stringValue)
        
        let content: JSON = ["content": messageTxtContent]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.EDIT_MESSAGE.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "pushMsgType": 4,
                                       "content": content]
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["subjectId"] = JSON(threadId)
        }
        if let repliedTo = params["repliedTo"].int {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        if let uniqueId = params["uniqueId"].string {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        if let metaData = params["metaData"].arrayObject {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: EditMessageCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (editMessageUniqueId) in
            uniqueId(editMessageUniqueId)
        }
        editMessageCallbackToUser = completion
    }
    
    
    /*
     ReplyTextMessage:
     send reply message to a messsage.
     
     By calling this function, a request of type 2 (FORWARD_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:    id of the message that you want to remove some participant it.    (Int)
     - content:      array of participants in the thread to remove them.
     - repliedTo:
     - uniqueId:
     - typeCode:
     - systemMetadata:
     - metaData:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- onSent:
     3- onDelivere:
     4- onSeen:
     */
    public func replyMessage(replyMessageInput: ReplyTextMessageRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             onSent:            @escaping callbackTypeAlias,
                             onDelivere:        @escaping callbackTypeAlias,
                             onSeen:            @escaping callbackTypeAlias) {
        log.verbose("Try to reply Message with this parameters: \n \(replyMessageInput)", context: "Chat")
        let tempUniqueId = generateUUID()
        
        // seve this message on the Cache Wait Queue,
        // so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which messages didn't send correctly, and can handle them
        let messageObjectToSendToQueue = QueueOfWaitTextMessagesModel(content:      replyMessageInput.content,
                                                                      metaData:     replyMessageInput.metaData,
                                                                      repliedTo:    replyMessageInput.repliedTo,
                                                                      systemMetadata: nil,
                                                                      threadId:     replyMessageInput.subjectId,
                                                                      typeCode:     replyMessageInput.typeCode,
                                                                      uniqueId:     replyMessageInput.uniqueId ?? tempUniqueId)
        Chat.cacheDB.saveTextMessageToWaitQueue(textMessage: messageObjectToSendToQueue)
        
        let messageTxtContent = makeCustomTextToSend(textMessage: replyMessageInput.content)
        //        let content: JSON = ["content": messageTxtContent]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MESSAGE.rawValue,
                                       "pushMsgType": 4,
                                       "repliedTo": replyMessageInput.repliedTo,
                                       "content": messageTxtContent,
                                       "typeCode": replyMessageInput.typeCode ?? generalTypeCode]
        
        if let uniqueId = replyMessageInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        } else {
            sendMessageParams["uniqueId"] = JSON(tempUniqueId)
        }
        
        if let metaData = replyMessageInput.metaData {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(parameters: sendMessageParams), deliverCallback: SendMessageCallbacks(parameters: sendMessageParams), seenCallback: SendMessageCallbacks(parameters: sendMessageParams)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'ReplyTextMessageRequestModel' to get the parameters, it'll use JSON
    public func replyMessageWith3Callbacks(params: JSON, uniqueId: @escaping (String) -> (), onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to reply Message with this parameters: \n \(params)", context: "Chat")
        
        let messageTxtContent = makeCustomTextToSend(textMessage: params["content"].stringValue)
        //        let content: JSON = ["content": messageTxtContent]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MESSAGE.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "pushMsgType": 4,
                                       "content": messageTxtContent]
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["subjectId"] = JSON(threadId)
        }
        if let repliedTo = params["repliedTo"].int {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        if let uniqueId = params["uniqueId"].string {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        if let metaData = params["metaData"].arrayObject {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        
        
        sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(parameters: sendMessageParams), deliverCallback: SendMessageCallbacks(parameters: sendMessageParams), seenCallback: SendMessageCallbacks(parameters: sendMessageParams)) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
    }
    
    
    /*
     ForwardTextMessage:
     forwar some messages to a thread.
     
     By calling this function, a request of type 22 (FORWARD_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:       id of the thread that you want to send messages.    (Int)
     - messageIds:      array of message ids to forward them.
     - repliedTo:
     - typeCode:
     - metaData:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- onSent:
     3- onDelivere:
     4- onSeen:
     */
    public func forwardMessage(forwardMessageInput: ForwardMessageRequestModel,
                               uniqueIds:           @escaping (String) -> (),
                               onSent:              @escaping callbackTypeAlias,
                               onDelivere:          @escaping callbackTypeAlias,
                               onSeen:              @escaping callbackTypeAlias) {
        log.verbose("Try to Forward with this parameters: \n \(forwardMessageInput)", context: "Chat")
        let tempUniqueId = generateUUID()
        
        // seve this message on the Cache Wait Queue,
        // so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which messages didn't send correctly, and can handle them
        let messageObjectToSendToQueue = QueueOfWaitForwardMessagesModel(messageIds: forwardMessageInput.messageIds,
                                                                         metaData:  forwardMessageInput.metaData,
                                                                         repliedTo: forwardMessageInput.repliedTo,
                                                                         subjectId: forwardMessageInput.subjectId,
                                                                         typeCode:  forwardMessageInput.typeCode,
                                                                         uniqueId:  tempUniqueId)
        Chat.cacheDB.saveForwardMessageToWaitQueue(forwardMessage: messageObjectToSendToQueue)
        
        
        let messageIdsList: [Int] = forwardMessageInput.messageIds
        var uniqueIdsList: [String] = []
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
                                       "pushMsgType": 4,
                                       "content": "\(messageIdsList)",
            "typeCode": forwardMessageInput.typeCode ?? generalTypeCode]
        
        if let repliedTo = forwardMessageInput.repliedTo {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        
        if let metaData = forwardMessageInput.metaData {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        
        let messageIdsListCount = messageIdsList.count
        for _ in 0...(messageIdsListCount - 1) {
            let uID = generateUUID()
            uniqueIdsList.append(uID)
            
            sendMessageParams["uniqueId"] = JSON("\(uniqueIdsList)")
            
            sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(parameters: sendMessageParams), deliverCallback: SendMessageCallbacks(parameters: sendMessageParams), seenCallback: SendMessageCallbacks(parameters: sendMessageParams)) { (theUniqueId) in
                uniqueIds(theUniqueId)
            }
            
            sendCallbackToUserOnSent = onSent
            sendCallbackToUserOnDeliver = onDelivere
            sendCallbackToUserOnSeen = onSeen
            
        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'ForwardMessageRequestModel' to get the parameters, it'll use JSON
    public func forwardMessageWith3Callbacks(params: JSON, uniqueIds: @escaping (String) -> (), onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to Forward with this parameters: \n \(params)", context: "Chat")
        /*
         subjectId(destination):    Int
         content:                   "[Arr]"
         */
        
        //        let threadId = params["subjectId"].intValue
        let messageIdsList: [Int] = params["content"].arrayObject! as! [Int]
        var uniqueIdsList: [String] = []
        //            let content: JSON = ["content": "\(messageIdsList)"]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "pushMsgType": 4,
                                       "content": "\(messageIdsList)"]
        
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["subjectId"] = JSON(threadId)
        }
        if let repliedTo = params["repliedTo"].int {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
        }
        if let metaData = params["metaData"].arrayObject {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
        }
        
        let messageIdsListCount = messageIdsList.count
        for _ in 0...(messageIdsListCount - 1) {
            let uID = generateUUID()
            uniqueIdsList.append(uID)
            
            sendMessageParams["uniqueId"] = JSON("\(uniqueIdsList)")
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(parameters: sendMessageParams), deliverCallback: SendMessageCallbacks(parameters: sendMessageParams), seenCallback: SendMessageCallbacks(parameters: sendMessageParams)) { (theUniqueId) in
            uniqueIds(theUniqueId)
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
        
        //        for _ in messageIdsList {
        //            let content: JSON = ["content": "\(messageIdsList)"]
        //            var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
        //                                           "pushMsgType": 4,
        //                                           "content": content]
        //
        //            if let threadId = params["subjectId"].int {
        //                sendMessageParams["subjectId"] = JSON(threadId)
        //            }
        //            if let repliedTo = params["repliedTo"].int {
        //                sendMessageParams["repliedTo"] = JSON(repliedTo)
        //            }
        //            if let uniqueId = params["uniqueId"].string {
        //                sendMessageParams["uniqueId"] = JSON(uniqueId)
        //            }
        //            if let metaData = params["metaData"].arrayObject {
        //                let metaDataStr = "\(metaData)"
        //                sendMessageParams["metaData"] = JSON(metaDataStr)
        //            }
        //            sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(), deliverCallback: SendMessageCallbacks(), seenCallback: SendMessageCallbacks()) { (theUniqueId) in
        //                uniqueIdsList.append(theUniqueId)
        //            }
        //
        //            sendCallbackToUserOnSent = onSent
        //            sendCallbackToUserOnDeliver = onDelivere
        //            sendCallbackToUserOnSeen = onSeen
        //        }
        //        uniqueIds(uniqueIdsList)
    }
    
    
    /*
     SendFileMessage:
     send some file and also send some message too with it.
     
     By calling this function, first an HTTP request of type (GET_IMAGE or GET_FILE), and then send message request of type 2 (MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - fileName:    name of the file (if there was any)
     - imageName:   name of the image (if there was any)
     - xC:
     - yC:
     - hC:
     - wC:
     - threadId:
     - subjectId:
     - repliedTo:
     - content:
     - metaData:
     - typeCode:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- onSent:
     3- onDelivered:
     4- onSeen:
     */
    public func sendFileMessage(sendFileMessageInput:   SendFileMessageRequestModel,
                                uniqueId:               @escaping (String) -> (),
                                uploadProgress:         @escaping (Float) -> (),
                                onSent:                 @escaping callbackTypeAlias,
                                onDelivered:            @escaping callbackTypeAlias,
                                onSeen:                 @escaping callbackTypeAlias) {
        log.verbose("Try to Send File adn Message with this parameters: \n \(sendFileMessageInput)", context: "Chat")
        let messageUniqueId = generateUUID()
        
        // seve this message on the Cache Wait Queue,
        // so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which messages didn't send correctly, and can handle them
//        let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:      sendFileMessageInput.content,
//                                                                      fileName:     sendFileMessageInput.fileName,
//                                                                      imageName:    sendFileMessageInput.imageName,
//                                                                      metaData:     sendFileMessageInput.metaData,
//                                                                      repliedTo:    sendFileMessageInput.repliedTo,
//                                                                      subjectId:    sendFileMessageInput.subjectId,
//                                                                      threadId:     sendFileMessageInput.threadId,
//                                                                      typeCode:     sendFileMessageInput.typeCode,
//                                                                      uniqueId:     messageUniqueId,
//                                                                      xC:           sendFileMessageInput.xC,
//                                                                      yC:           sendFileMessageInput.yC,
//                                                                      hC:           sendFileMessageInput.hC,
//                                                                      wC:           sendFileMessageInput.wC,
//                                                                      fileToSend:   sendFileMessageInput.fileToSend,
//                                                                      imageToSend:  sendFileMessageInput.imageToSend)
        // this line couses an error!!
//        Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
        
        var fileName:       String  = ""
        var fileType:       String  = ""
        var fileSize:       Int     = 0
        var fileExtension:  String  = ""
        
        if let myFileName = sendFileMessageInput.fileName {
            fileName = myFileName
        } else if let myImageName = sendFileMessageInput.imageName {
            fileName = myImageName
        }
        
        let uploadUniqueId = generateUUID()
        
        var metaData: JSON = [:]
        metaData["file"]["originalName"] = JSON(fileName)
        metaData["file"]["mimeType"] = JSON(fileType)
        metaData["file"]["size"] = JSON(fileSize)
        
        var paramsToSendToUpload: JSON = ["uniqueId": uploadUniqueId, "originalFileName": fileName]
        
        if let xC = sendFileMessageInput.xC {
            paramsToSendToUpload["xC"] = JSON(xC)
        }
        if let yC = sendFileMessageInput.yC {
            paramsToSendToUpload["yC"] = JSON(yC)
        }
        if let hC = sendFileMessageInput.hC {
            paramsToSendToUpload["hC"] = JSON(hC)
        }
        if let wC = sendFileMessageInput.wC {
            paramsToSendToUpload["wC"] = JSON(wC)
        }
        if let fileName = sendFileMessageInput.fileName {
            paramsToSendToUpload["fileName"] = JSON(fileName)
        } else {
            paramsToSendToUpload["fileName"] = JSON(uploadUniqueId)
        }
        if let threadId = sendFileMessageInput.threadId {
            paramsToSendToUpload["threadId"] = JSON(threadId)
        }
        
        uniqueId(messageUniqueId)
        
        var paramsToSendToSendMessage: JSON = ["uniqueId": messageUniqueId,
                                               "typeCode": sendFileMessageInput.typeCode ?? generalTypeCode]
        
        if let subjectId = sendFileMessageInput.subjectId {
            paramsToSendToSendMessage["subjectId"] = JSON(subjectId)
            paramsToSendToSendMessage["threadId"] = JSON(subjectId)
        }
        if let repliedTo = sendFileMessageInput.repliedTo {
            paramsToSendToSendMessage["repliedTo"] = JSON(repliedTo)
        }
        if let content = sendFileMessageInput.content {
            paramsToSendToSendMessage["content"] = JSON("\(content)")
        }
        if let systemMetadata = sendFileMessageInput.metaData {
            paramsToSendToSendMessage["systemMetadata"] = JSON("\(systemMetadata)")
        }
        
        
        if let image = sendFileMessageInput.imageToSend {
            uploadImage(params: paramsToSendToUpload, dataToSend: image, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                
                let myResponse: UploadImageModel = response as! UploadImageModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage!.id ?? 0)&hashCode=\(myResponse.uploadImage!.hashCode ?? "")"
                
                var fileJSON : JSON = [:]
                
                fileJSON["link"]            = JSON(link)
                fileJSON["id"]              = JSON(myResponse.uploadImage!.id ?? 0)
                fileJSON["name"]            = JSON(myResponse.uploadImage!.name ?? "")
                fileJSON["height"]          = JSON(myResponse.uploadImage!.height ?? 0)
                fileJSON["width"]           = JSON(myResponse.uploadImage!.width ?? 0)
                fileJSON["actualHeight"]    = JSON(myResponse.uploadImage!.actualHeight ?? 0)
                fileJSON["actualWidth"]     = JSON(myResponse.uploadImage!.actualWidth ?? 0)
                fileJSON["hashCode"]        = JSON(myResponse.uploadImage!.hashCode ?? "")
                
                metaData["file"] = fileJSON
                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
                
                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
            }
        } else if let file = sendFileMessageInput.fileToSend {
            uploadFile(params: paramsToSendToUpload, dataToSend: file, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                
                let myResponse: UploadFileModel = response as! UploadFileModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile!.id ?? 0)&hashCode=\(myResponse.uploadFile!.hashCode ?? "")"
                
                var fileJSON : JSON = [:]
                
                fileJSON["link"]        = JSON(link)
                fileJSON["id"]          = JSON(myResponse.uploadFile!.id ?? 0)
                fileJSON["name"]        = JSON(myResponse.uploadFile!.name ?? "")
                fileJSON["hashCode"]    = JSON(myResponse.uploadFile!.hashCode ?? "")
                
                metaData["file"] = fileJSON
                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
                
                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
            }
        }
        
        // if there was no data to send, then returns an error to user
        if (sendFileMessageInput.imageToSend == nil) && (sendFileMessageInput.fileToSend == nil) {
            delegate?.chatError(errorCode: 6302, errorMessage: CHAT_ERRORS.err6302.rawValue, errorResult: nil)
        }
        
        
        // this will call when all data were uploaded and it will sends the textMessage
        func sendMessageWith(paramsToSendToSendMessage: JSON) {
            let sendMessageParamModel = SendTextMessageRequestModel(content:        paramsToSendToSendMessage["content"].stringValue,
                                                                    metaData:       paramsToSendToSendMessage["metaData"],
                                                                    repliedTo:      paramsToSendToSendMessage["repliedTo"].int,
                                                                    systemMetadata: paramsToSendToSendMessage["systemMetadata"],
                                                                    threadId:       paramsToSendToSendMessage["threadId"].intValue,
                                                                    typeCode:       paramsToSendToSendMessage["typeCode"].string,
                                                                    uniqueId:       paramsToSendToSendMessage["uniqueId"].string)
            
            
            self.sendTextMessage(sendTextMessageInput: sendMessageParamModel, uniqueId: { _ in }, onSent: { (sent) in
                onSent(sent)
            }, onDelivere: { (delivered) in
                onDelivered(delivered)
            }, onSeen: { (seen) in
                onSeen(seen)
            })
            
        }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'SendFileMessageRequestModel' to get the parameters, it'll use JSON
    public func sendFileMessage(textMessagParams: JSON, fileParams: JSON, imageToSend: Data?, fileToSend: Data?, uniqueId: @escaping (String) -> (), uploadProgress: @escaping (Float) -> (), onSent: @escaping callbackTypeAlias, onDelivered: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        log.verbose("Try to Send File adn Message with this parameters: \n \(textMessagParams)", context: "Chat")
        
        var fileName:       String  = ""
        var fileType:       String  = ""
        var fileSize:       Int     = 0
        var fileExtension:  String  = ""
        
        if let myFileName = fileParams["fileName"].string {
            fileName = myFileName
        } else if let myImageName = fileParams["imageName"].string {
            fileName = myImageName
        }
        
        let uploadUniqueId: String = generateUUID()
        
        var metaData: JSON = [:]
        
        metaData["file"]["originalName"] = JSON(fileName)
        metaData["file"]["mimeType"] = JSON(fileType)
        metaData["file"]["size"] = JSON(fileSize)
        
        var paramsToSendToUpload: JSON = ["uniqueId": uploadUniqueId, "originalFileName": fileName]
        
        if let xC = fileParams["xC"].string {
            paramsToSendToUpload["xC"] = JSON(xC)
        }
        if let yC = fileParams["yC"].string {
            paramsToSendToUpload["yC"] = JSON(yC)
        }
        if let hC = fileParams["hC"].string {
            paramsToSendToUpload["hC"] = JSON(hC)
        }
        if let wC = fileParams["wC"].string {
            paramsToSendToUpload["wC"] = JSON(wC)
        }
        if let fileName = fileParams["fileName"].string {
            paramsToSendToUpload["fileName"] = JSON(fileName)
        } else {
            paramsToSendToUpload["fileName"] = JSON(uploadUniqueId)
        }
        if let threadId = fileParams["threadId"].int {
            paramsToSendToUpload["threadId"] = JSON(threadId)
        }
        
        
        let messageUniqueId = generateUUID()
        uniqueId(messageUniqueId)
        
        var paramsToSendToSendMessage: JSON = ["uniqueId": messageUniqueId,
                                               "typeCode": textMessagParams["typeCode"].string ?? generalTypeCode]
        
        if let subjectId = textMessagParams["subjectId"].int {
            paramsToSendToSendMessage["subjectId"] = JSON(subjectId)
        }
        if let repliedTo = textMessagParams["repliedTo"].int {
            paramsToSendToSendMessage["repliedTo"] = JSON(repliedTo)
        }
        if let content = textMessagParams["content"].string {
            paramsToSendToSendMessage["content"] = JSON(content)
        }
        if let systemMetadata = textMessagParams["metadata"].string {
            paramsToSendToSendMessage["systemMetadata"] = JSON(systemMetadata)
        }
        
        
        if let image = imageToSend {
            uploadImage(params: paramsToSendToUpload, dataToSend: image, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                
                let myResponse: UploadImageModel = response as! UploadImageModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage!.id ?? 0)&hashCode=\(myResponse.uploadImage!.hashCode ?? "")"
                metaData["file"]["link"]            = JSON(link)
                metaData["file"]["id"]              = JSON(myResponse.uploadImage!.id ?? 0)
                metaData["file"]["name"]            = JSON(myResponse.uploadImage!.name ?? "")
                metaData["file"]["height"]          = JSON(myResponse.uploadImage!.height ?? 0)
                metaData["file"]["width"]           = JSON(myResponse.uploadImage!.width ?? 0)
                metaData["file"]["actualHeight"]    = JSON(myResponse.uploadImage!.actualHeight ?? 0)
                metaData["file"]["actualWidth"]     = JSON(myResponse.uploadImage!.actualWidth ?? 0)
                metaData["file"]["hashCode"]        = JSON(myResponse.uploadImage!.hashCode ?? "")
                
                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
                
                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
            }
        } else if let file = fileToSend {
            uploadFile(params: paramsToSendToUpload, dataToSend: file, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                
                let myResponse: UploadFileModel = response as! UploadFileModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile!.id ?? 0)&hashCode=\(myResponse.uploadFile!.hashCode ?? "")"
                metaData["file"]["link"]            = JSON(link)
                metaData["file"]["id"]              = JSON(myResponse.uploadFile!.id ?? 0)
                metaData["file"]["name"]            = JSON(myResponse.uploadFile!.name ?? "")
                metaData["file"]["hashCode"]        = JSON(myResponse.uploadFile!.hashCode ?? "")
                
                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
                
                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
            }
        }
        
        // if there was no data to send, then returns an error to user
        if (imageToSend == nil) && (fileToSend == nil) {
            delegate?.chatError(errorCode: 6302, errorMessage: CHAT_ERRORS.err6302.rawValue, errorResult: nil)
        }
        
        
        // this will call when all data were uploaded and it will sends the textMessage
        func sendMessageWith(paramsToSendToSendMessage: JSON) {
            self.sendTextMessage(params: paramsToSendToSendMessage, uniqueId: { _ in}, onSent: { (sent) in
                onSent(sent)
            }, onDelivere: { (delivered) in
                onDelivered(delivered)
            }, onSeen: { (seen) in
                onSeen(seen)
            })
        }
        
    }
    
    
    
    /*
     Reply File Message:
     
     this function is almost the same as SendFileMessage function
     */
    public func replyFileMessage(replyFileMessageInput: SendFileMessageRequestModel,
                                 uniqueId:              @escaping (String) -> (),
                                 uploadProgress:        @escaping (Float) -> (),
                                 onSent:                @escaping callbackTypeAlias,
                                 onDelivered:           @escaping callbackTypeAlias,
                                 onSeen:                @escaping callbackTypeAlias) {
        log.verbose("Try to reply File Message with this parameters: \n \(replyFileMessageInput)", context: "Chat")
        let uploadUniqueId = generateUUID()
        
        // seve this message on the Cache Wait Queue,
        // so if there was an situation that response of the server to this message doesn't come, then we know that our message didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which messages didn't send correctly, and can handle them
        let messageObjectToSendToQueue = QueueOfWaitFileMessagesModel(content:      replyFileMessageInput.content,
                                                                      fileName:     replyFileMessageInput.fileName,
                                                                      imageName:    replyFileMessageInput.imageName,
                                                                      metaData:     replyFileMessageInput.metaData,
                                                                      repliedTo:    replyFileMessageInput.repliedTo,
                                                                      subjectId:    replyFileMessageInput.subjectId,
                                                                      threadId:     replyFileMessageInput.threadId,
                                                                      typeCode:     replyFileMessageInput.typeCode,
                                                                      uniqueId:     uploadUniqueId,
                                                                      xC:           replyFileMessageInput.xC,
                                                                      yC:           replyFileMessageInput.yC,
                                                                      hC:           replyFileMessageInput.hC,
                                                                      wC:           replyFileMessageInput.wC,
                                                                      fileToSend:   replyFileMessageInput.fileToSend,
                                                                      imageToSend:  replyFileMessageInput.imageToSend)
        Chat.cacheDB.saveFileMessageToWaitQueue(fileMessage: messageObjectToSendToQueue)
        
        
        var fileName:       String  = ""
        var fileType:       String  = ""
        var fileSize:       Int     = 0
        var fileExtension:  String  = ""
        
        if let myFileName = replyFileMessageInput.fileName {
            fileName = myFileName
        } else if let myImageName = replyFileMessageInput.imageName {
            fileName = myImageName
        }
        
        var metaData: JSON = [:]
        metaData["file"]["originalName"] = JSON(fileName)
        metaData["file"]["mimeType"] = JSON(fileType)
        metaData["file"]["size"] = JSON(fileSize)
        
        var paramsToSendToUpload: JSON = ["uniqueId": uploadUniqueId, "originalFileName": fileName]
        
        if let xC = replyFileMessageInput.xC {
            paramsToSendToUpload["xC"] = JSON(xC)
        }
        if let yC = replyFileMessageInput.yC {
            paramsToSendToUpload["yC"] = JSON(yC)
        }
        if let hC = replyFileMessageInput.hC {
            paramsToSendToUpload["hC"] = JSON(hC)
        }
        if let wC = replyFileMessageInput.wC {
            paramsToSendToUpload["wC"] = JSON(wC)
        }
        if let fileName = replyFileMessageInput.fileName {
            paramsToSendToUpload["fileName"] = JSON(fileName)
        } else {
            paramsToSendToUpload["fileName"] = JSON(uploadUniqueId)
        }
        if let threadId = replyFileMessageInput.threadId {
            paramsToSendToUpload["threadId"] = JSON(threadId)
        }
        
        let messageUniqueId = generateUUID()
        uniqueId(messageUniqueId)
        
        var paramsToSendToSendMessage: JSON = ["uniqueId": messageUniqueId,
                                               "typeCode": replyFileMessageInput.typeCode ?? generalTypeCode]
        
        if let subjectId = replyFileMessageInput.subjectId {
            paramsToSendToSendMessage["subjectId"] = JSON(subjectId)
        }
        if let repliedTo = replyFileMessageInput.repliedTo {
            paramsToSendToSendMessage["repliedTo"] = JSON(repliedTo)
        }
        if let content = replyFileMessageInput.content {
            paramsToSendToSendMessage["content"] = JSON("\(content)")
        }
        if let systemMetadata = replyFileMessageInput.metaData {
            paramsToSendToSendMessage["systemMetadata"] = JSON("\(systemMetadata)")
        }
        
        
        if let image = replyFileMessageInput.imageToSend {
            uploadImage(params: paramsToSendToUpload, dataToSend: image, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                
                let myResponse: UploadImageModel = response as! UploadImageModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage!.id ?? 0)&hashCode=\(myResponse.uploadImage!.hashCode ?? "")"
                metaData["file"]["link"]            = JSON(link)
                metaData["file"]["id"]              = JSON(myResponse.uploadImage!.id ?? 0)
                metaData["file"]["name"]            = JSON(myResponse.uploadImage!.name ?? "")
                metaData["file"]["height"]          = JSON(myResponse.uploadImage!.height ?? 0)
                metaData["file"]["width"]           = JSON(myResponse.uploadImage!.width ?? 0)
                metaData["file"]["actualHeight"]    = JSON(myResponse.uploadImage!.actualHeight ?? 0)
                metaData["file"]["actualWidth"]     = JSON(myResponse.uploadImage!.actualWidth ?? 0)
                metaData["file"]["hashCode"]        = JSON(myResponse.uploadImage!.hashCode ?? "")
                
                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
                
                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
            }
        } else if let file = replyFileMessageInput.fileToSend {
            uploadFile(params: paramsToSendToUpload, dataToSend: file, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                
                let myResponse: UploadFileModel = response as! UploadFileModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile!.id ?? 0)&hashCode=\(myResponse.uploadFile!.hashCode ?? "")"
                metaData["file"]["link"]            = JSON(link)
                metaData["file"]["id"]              = JSON(myResponse.uploadFile!.id ?? 0)
                metaData["file"]["name"]            = JSON(myResponse.uploadFile!.name ?? "")
                metaData["file"]["hashCode"]        = JSON(myResponse.uploadFile!.hashCode ?? "")
                
                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
                
                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
            }
        }
        
        // if there was no data to send, then returns an error to user
        if (replyFileMessageInput.imageToSend == nil) && (replyFileMessageInput.fileToSend == nil) {
            delegate?.chatError(errorCode: 6302, errorMessage: CHAT_ERRORS.err6302.rawValue, errorResult: nil)
        }
        
        
        // this will call when all data were uploaded and it will sends the textMessage
        func sendMessageWith(paramsToSendToSendMessage: JSON) {
            let sendMessageParamModel = SendTextMessageRequestModel(content:        paramsToSendToSendMessage["content"].stringValue,
                                                                    metaData:       paramsToSendToSendMessage["metaData"],
                                                                    repliedTo:      paramsToSendToSendMessage["repliedTo"].int,
                                                                    systemMetadata: paramsToSendToSendMessage["systemMetadata"],
                                                                    threadId:       paramsToSendToSendMessage["threadId"].intValue,
                                                                    typeCode:       paramsToSendToSendMessage["typeCode"].string,
                                                                    uniqueId:       paramsToSendToSendMessage["uniqueId"].string)
            
            self.sendTextMessage(sendTextMessageInput: sendMessageParamModel, uniqueId: { _ in }, onSent: { (sent) in
                onSent(sent)
            }, onDelivere: { (delivered) in
                onDelivered(delivered)
            }, onSeen: { (seen) in
                onSeen(seen)
            })
            
        }
        
    }
    
    
    
    
    
    
    /*
     DeleteMessage:
     delete specific message by getting message id.
     
     By calling this function, a request of type 29 (DELETE_MESSAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:       id of the thread that you want to send messages.    (Int)
     - deleteForAll:
     - uniqueId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func deleteMessage(deleteMessageInput:   DeleteMessageRequestModel,
                              uniqueId:             @escaping (String) -> (),
                              completion:           @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(deleteMessageInput)", context: "Chat")
        
        var content: JSON = []
        if let deleteForAll = deleteMessageInput.deleteForAll {
            content["deleteForAll"] = JSON("\(deleteForAll)")
        }
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                       "typeCode": deleteMessageInput.typeCode ?? generalTypeCode,
                                       "pushMsgType": 4,
                                       "content": content]
        
        if let threadId = deleteMessageInput.subjectId {
            sendMessageParams["subjectId"] = JSON(threadId)
        }
        
        if let uniqueId = deleteMessageInput.uniqueId {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: DeleteMessageCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (deleteMessageUniqueId) in
            uniqueId(deleteMessageUniqueId)
        }
        deleteMessageCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'DeleteMessageRequestModel' to get the parameters, it'll use JSON
    public func deleteMessage(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to edit message with this parameters: \n \(params)", context: "Chat")
        
        let deleteForAllVar = params["deleteForAll"]
        let content: JSON = ["deleteForAll": "\(deleteForAllVar)"]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELETE_MESSAGE.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode,
                                       "pushMsgType": 4,
                                       "content": content]
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["subjectId"] = JSON(threadId)
        }
        if let uniqueId = params["uniqueId"].string {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: DeleteMessageCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (deleteMessageUniqueId) in
            uniqueId(deleteMessageUniqueId)
        }
        deleteMessageCallbackToUser = completion
    }
    
    
    
    public func cancelSendMessage(cancelMessageInput: CancelMessageRequestModel,
                                  completion: @escaping (Bool) -> ()) {
        if let textUID = cancelMessageInput.textMessageUniqueId {
            Chat.cacheDB.deleteWaitTextMessage(uniqueId: textUID)
            completion(true)
        }
        if let editUID = cancelMessageInput.editMessageUniqueId {
            Chat.cacheDB.deleteWaitEditMessage(uniqueId: editUID)
            completion(true)
        }
        if let forwardUID = cancelMessageInput.forwardMessageUniqueId {
            Chat.cacheDB.deleteWaitForwardMessage(uniqueId: forwardUID)
            completion(true)
        }
        if let fileUID = cancelMessageInput.fileMessageUniqueId {
            Chat.cacheDB.deleteWaitFileMessage(uniqueId: fileUID)
            completion(true)
        }
        if let uploadImageUID = cancelMessageInput.uploadImageUniqueId {
            manageUpload(image: true, file: false, withUniqueId: uploadImageUID, withAction: .cancel) { (response, state) in
                completion(state)
            }
        }
        if let uploadFileUID = cancelMessageInput.uploadFileUniqueId {
            manageUpload(image: false, file: true, withUniqueId: uploadFileUID, withAction: .cancel) { (response, state) in
                completion(state)
            }
        }
    }
    
    
    // MARK: - File Management
    
    /*
     UploadImage:
     upload some image.
     
     By calling this function, HTTP request of type (UPLOAD_IMAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - fileExtension:
     - fileName:   name of the image
     - fileSize:
     - threadId:
     - uniqueId:
     - originalFileName:
     - xC:
     - yC:
     - hC:
     - wC:
     
     + Outputs:
     It has 4 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func uploadImage(uploadImageInput:   UploadImageRequestModel,
                            uniqueId:           @escaping (String) -> (),
                            progress:           @escaping (Float) -> (),
                            completion:         @escaping callbackTypeAlias) {
        log.verbose("Try to upload image with this parameters: \n \(uploadImageInput)", context: "Chat")
        let uploadUniqueId = generateUUID()
        
        // seve this upload image on the Cache Wait Queue,
        // so if there was an situation that response of the server to this uploading doesn't come, then we know that our upload request didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which upload requests didn't send correctly, and can handle them
        let messageObjectToSendToQueue = QueueOfWaitUploadImagesModel(dataToSend:         uploadImageInput.dataToSend,
                                                                      fileExtension:      uploadImageInput.fileExtension,
                                                                      fileName:           uploadImageInput.fileName,
                                                                      fileSize:           uploadImageInput.fileSize,
                                                                      originalFileName:   uploadImageInput.originalFileName,
                                                                      threadId:           uploadImageInput.threadId,
                                                                      uniqueId:           uploadImageInput.uniqueId ?? uploadUniqueId,
                                                                      xC:                 uploadImageInput.xC,
                                                                      yC:                 uploadImageInput.yC,
                                                                      hC:                 uploadImageInput.hC,
                                                                      wC:                 uploadImageInput.wC)
        Chat.cacheDB.saveUploadImageToWaitQueue(image: messageObjectToSendToQueue)
        
        
        var fileName:           String  = ""
        //        var fileType:           String  = ""
        //        var fileSize:           Int     = 0
        var fileExtension:      String  = ""
        
        var uploadFileData: JSON = [:]
        
        if let myFileExtension = uploadImageInput.fileExtension {
            fileExtension = myFileExtension
        }
        
        if let myFileName = uploadImageInput.fileName {
            fileName = myFileName
        } else {
            let myFileName = "\(generateUUID()).\(fileExtension)"
            fileName = myFileName
        }
        
        if let myFileSize = uploadImageInput.fileSize {
            uploadFileData["fileSize"] = JSON(myFileSize)
        }
        
        if let threadId = uploadImageInput.threadId {
            uploadFileData["threadId"] = JSON(threadId)
        }
        
        if let myUniqueId = uploadImageInput.uniqueId {
            uploadFileData["uniqueId"] = JSON(myUniqueId)
            uniqueId(myUniqueId)
        } else {
            uploadFileData["uniqueId"] = JSON(uploadUniqueId)
            uniqueId(uploadUniqueId)
        }
        
        if let myOriginalFileName = uploadImageInput.originalFileName {
            uploadFileData["originalFileName"] = JSON(myOriginalFileName)
        }
        
        uploadFileData["fileName"] = JSON(fileName)
        
        if let xC = uploadImageInput.xC {
            uploadFileData["xC"] = JSON(xC)
        }
        
        if let yC = uploadImageInput.yC {
            uploadFileData["yC"] = JSON(yC)
        }
        
        if let hC = uploadImageInput.hC {
            uploadFileData["hC"] = JSON(hC)
        }
        
        if let wC = uploadImageInput.wC {
            uploadFileData["wC"] = JSON(wC)
        }
        
        /*
         *  + data:
         *      -image:             String
         *      -fileName:          String
         *      -fileSize:          Int
         *      -threadId:          Int
         *      -uniqueId:          String
         *      -originalFileName:  String
         */
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.UPLOAD_IMAGE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.post
        let headers:    HTTPHeaders = ["_token_": token, "_token_issuer_": "1", "Content-type": "multipart/form-data"]
        let parameters: Parameters = ["fileName": fileName]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: parameters, dataToSend: uploadImageInput.dataToSend, requestUniqueId: uploadFileData["uniqueId"].stringValue, isImage: true, isFile: false, completion: { (response) in
            
            let myResponse: JSON = response as! JSON
            let hasError        = myResponse["hasError"].boolValue
            let errorMessage    = myResponse["errorMessage"].stringValue
            let errorCode       = myResponse["errorCode"].intValue
            
            if (!hasError) {
                let resultData = myResponse["result"]
                
                // save data comes from server to the Cache
                let uploadImageFile = UploadImage(messageContent: resultData)
                Chat.cacheDB.saveUploadImage(imageInfo: uploadImageFile, imageData: uploadImageInput.dataToSend)
                
                
                let uploadImageModel = UploadImageModel(messageContentJSON: resultData, errorCode: errorCode, errorMessage: errorMessage, hasError: hasError)
                
                completion(uploadImageModel)
            }
            
        }, progress: { (myProgress) in
            progress(myProgress)
        }, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'UploadImageRequestModel' to get the parameters, it'll use JSON
    public func uploadImage(params: JSON, dataToSend: Data, uniqueId: @escaping (String) -> (), progress: @escaping (Float) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to upload image with this parameters: \n \(params)", context: "Chat")
        
        var fileName:           String  = ""
        //        var fileType:           String  = ""
        //        var fileSize:           Int     = 0
        var fileExtension:      String  = ""
        
        var uploadFileData: JSON = [:]
        
        if let myFileExtension = params["fileExtension"].string {
            fileExtension = myFileExtension
        }
        
        if let myFileName = params["fileName"].string {
            fileName = myFileName
        } else {
            let myFileName = "\(generateUUID()).\(fileExtension)"
            fileName = myFileName
        }
        
        if let myFileSize = params["fileSize"].int {
            uploadFileData["fileSize"] = JSON(myFileSize)
        }
        
        if let threadId = params["threadId"].int {
            uploadFileData["threadId"] = JSON(threadId)
        }
        
        if let myUniqueId = params["uniqueId"].string {
            uploadFileData["uniqueId"] = JSON(myUniqueId)
            uniqueId(myUniqueId)
        } else {
            let myUniqueId = generateUUID()
            uploadFileData["uniqueId"] = JSON(myUniqueId)
            uniqueId(myUniqueId)
        }
        
        if let myOriginalFileName = params["originalFileName"].string {
            uploadFileData["originalFileName"] = JSON(myOriginalFileName)
        }
        
        uploadFileData["fileName"] = JSON(fileName)
        
        if let xC = params["xC"].int {
            uploadFileData["xC"] = JSON(xC)
        }
        
        if let yC = params["yC"].int {
            uploadFileData["yC"] = JSON(yC)
        }
        
        if let hC = params["hC"].int {
            uploadFileData["hC"] = JSON(hC)
        }
        
        if let wC = params["wC"].int {
            uploadFileData["wC"] = JSON(wC)
        }
        
        /*
         *  + data:
         *      -image:             String
         *      -fileName:          String
         *      -fileSize:          Int
         *      -threadId:          Int
         *      -uniqueId:          String
         *      -originalFileName:  String
         */
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.UPLOAD_IMAGE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.post
        let headers:    HTTPHeaders = ["_token_": token, "_token_issuer_": "1", "Content-type": "multipart/form-data"]
        let parameters: Parameters = ["fileName": fileName]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: parameters, dataToSend: dataToSend, requestUniqueId: uploadFileData["uniqueId"].stringValue, isImage: true, isFile: false, completion: { (response) in
            
            let myResponse: JSON = response as! JSON
            let hasError        = myResponse["hasError"].boolValue
            let errorMessage    = myResponse["errorMessage"].stringValue
            let errorCode       = myResponse["errorCode"].intValue
            
            if (!hasError) {
                let resultData = myResponse["result"]
                let uploadImageModel = UploadImageModel(messageContentJSON: resultData, errorCode: errorCode, errorMessage: errorMessage, hasError: hasError)
                
                completion(uploadImageModel)
            }
            
        }, progress: { (myProgress) in
            progress(myProgress)
        }, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    
    
    /*
     UploadFile:
     upload some file.
     
     By calling this function, HTTP request of type (UPLOAD_FILE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - fileExtension:
     - fileName:   name of the image
     - fileSize:
     - threadId:
     - uniqueId:
     - originalFileName:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func uploadFile(uploadFileInput: UploadFileRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           progress:        @escaping (Float) -> (),
                           completion:      @escaping callbackTypeAlias) {
        log.verbose("Try to upload file with this parameters: \n \(uploadFileInput)", context: "Chat")
        let uploadUniqueId = generateUUID()
        
        // seve this upload image on the Cache Wait Queue,
        // so if there was an situation that response of the server to this uploading doesn't come, then we know that our upload request didn't sent correctly
        // and we will send this Queue to user on the GetHistory request,
        // now user knows which upload requests didn't send correctly, and can handle them
        let messageObjectToSendToQueue = QueueOfWaitUploadFilesModel(dataToSend: uploadFileInput.dataToSend,
                                                                     fileExtension: uploadFileInput.fileExtension,
                                                                     fileName: uploadFileInput.fileName,
                                                                     fileSize: uploadFileInput.fileSize,
                                                                     originalFileName: uploadFileInput.originalFileName,
                                                                     threadId: uploadFileInput.threadId,
                                                                     uniqueId: uploadFileInput.uniqueId)
        Chat.cacheDB.saveUploadFileToWaitQueue(file: messageObjectToSendToQueue)
        
        
        var fileName:           String  = ""
        //        var fileType:           String  = ""
        var fileSize:           Int     = 0
        var fileExtension:      String  = ""
        
        var uploadThreadId:     Int     = 0
        var originalFileName:   String  = ""
        
        var uploadFileData: JSON = [:]
        
        if let myFileExtension = uploadFileInput.fileExtension {
            fileExtension = myFileExtension
        }
        
        if let myFileName = uploadFileInput.fileName {
            fileName = myFileName
        } else {
            let myFileName = "\(generateUUID()).\(fileExtension)"
            fileName = myFileName
        }
        
        if let myFileSize = uploadFileInput.fileSize {
            fileSize = myFileSize
        }
        
        if let threadId = uploadFileInput.threadId {
            uploadThreadId = threadId
        }
        
        if let myUniqueId = uploadFileInput.uniqueId {
            uploadFileData["uniqueId"] = JSON(myUniqueId)
        } else {
            uploadFileData["uniqueId"] = JSON(uploadUniqueId)
        }
        
        if let myOriginalFileName = uploadFileInput.originalFileName {
            originalFileName = myOriginalFileName
        } else {
            originalFileName = fileName
        }
        
        uploadFileData["fileName"] = JSON(fileName)
        uploadFileData["threadId"] = JSON(uploadThreadId)
        uploadFileData["fileSize"] = JSON(fileSize)
//        uploadFileData["uniqueId"] = JSON(uploadUniqueId)
        uploadFileData["originalFileName"] = JSON(originalFileName)
        
        uniqueId(uploadUniqueId)
        
        /*
         *  + data:
         *      -file:              String
         *      -fileName:          String
         *      -fileSize:          Int
         *      -threadId:          Int
         *      -uniqueId:          String
         *      -originalFileName:  String
         */
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.UPLOAD_FILE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.post
        let headers:    HTTPHeaders = ["_token_": token, "_token_issuer_": "1", "Content-type": "multipart/form-data"]
        let parameters: Parameters = ["fileName": fileName]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: parameters, dataToSend: uploadFileInput.dataToSend, requestUniqueId: uploadFileData["uniqueId"].stringValue, isImage: false, isFile: true, completion: { (response) in
            
            let myResponse: JSON = response as! JSON
            
            let hasError        = myResponse["hasError"].boolValue
            let errorMessage    = myResponse["errorMessage"].stringValue
            let errorCode       = myResponse["errorCode"].intValue
            
            if (!hasError) {
                let resultData = myResponse["result"]
                
                // save data comes from server to the Cache
                let uploadFileFile = UploadFile(messageContent: resultData)
                Chat.cacheDB.saveUploadFile(fileInfo: uploadFileFile, fileData: uploadFileInput.dataToSend)
                
//                Chat.cacheDB.deleteWaitUploadFiles(uniqueId: )
                
                let uploadFileModel = UploadFileModel(messageContentJSON: resultData, errorCode: errorCode, errorMessage: errorMessage, hasError: hasError)
                
                completion(uploadFileModel)
            }
        }, progress: { (myProgress) in
            progress(myProgress)
        }, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'UploadFileRequestModel' to get the parameters, it'll use JSON
    public func uploadFile(params: JSON, dataToSend: Data, uniqueId: @escaping (String) -> (), progress: @escaping (Float) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to upload file with this parameters: \n \(params)", context: "Chat")
        
        var fileName:           String  = ""
        //        var fileType:           String  = ""
        var fileSize:           Int     = 0
        var fileExtension:      String  = ""
        
        var uploadThreadId:     Int     = 0
        var uploadUniqueId:     String  = ""
        var originalFileName:   String  = ""
        
        var uploadFileData: JSON = [:]
        
        if let myFileExtension = params["fileExtension"].string {
            fileExtension = myFileExtension
        }
        
        if let myFileName = params["fileName"].string {
            fileName = myFileName
        } else {
            let myFileName = "\(generateUUID()).\(fileExtension)"
            fileName = myFileName
        }
        
        if let myFileSize = params["fileSize"].int {
            fileSize = myFileSize
        }
        
        if let threadId = params["threadId"].int {
            uploadThreadId = threadId
        }
        
        if let myUniqueId = params["uniqueId"].string {
            uploadUniqueId = myUniqueId
        } else {
            let myUniqueId = generateUUID()
            uploadUniqueId = myUniqueId
        }
        
        if let myOriginalFileName = params["originalFileName"].string {
            originalFileName = myOriginalFileName
        } else {
            originalFileName = fileName
        }
        
        uploadFileData["fileName"] = JSON(fileName)
        uploadFileData["threadId"] = JSON(uploadThreadId)
        uploadFileData["fileSize"] = JSON(fileSize)
        uploadFileData["uniqueId"] = JSON(uploadUniqueId)
        uploadFileData["originalFileName"] = JSON(originalFileName)
        
        uniqueId(uploadUniqueId)
        
        /*
         *  + data:
         *      -file:              String
         *      -fileName:          String
         *      -fileSize:          Int
         *      -threadId:          Int
         *      -uniqueId:          String
         *      -originalFileName:  String
         */
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.UPLOAD_FILE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.post
        let headers:    HTTPHeaders = ["_token_": token, "_token_issuer_": "1", "Content-type": "multipart/form-data"]
        let parameters: Parameters = ["fileName": fileName]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: parameters, dataToSend: dataToSend, requestUniqueId: uploadUniqueId, isImage: false, isFile: true, completion: { (response) in
            
            let myResponse: JSON = response as! JSON
            
            let hasError        = myResponse["hasError"].boolValue
            let errorMessage    = myResponse["errorMessage"].stringValue
            let errorCode       = myResponse["errorCode"].intValue
            
            if (!hasError) {
                let resultData = myResponse["result"]
                let uploadFileModel = UploadFileModel(messageContentJSON: resultData, errorCode: errorCode, errorMessage: errorMessage, hasError: hasError)
                
                completion(uploadFileModel)
            }
        }, progress: { (myProgress) in
            progress(myProgress)
        }, idDownloadRequest: false, isMapServiceRequst: false) { _,_ in }
        
    }
    
    
    /*
     GetImage:
     get specific image.
     
     By calling this function, HTTP request of type (GET_IMAGE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as 'GetImageRequestModel' Model which are:
     - actual:
     - downloadable:
     - hashCode:
     - height:
     - imageId:
     - width:
     
     + Outputs:
     It has 3 callbacks as response:
     1- progress:       The progress of the downloading file as a number between 0 and 1.   (Float)
     2- completion:     when the file completely downloaded, it will sent to client as 'UploadImageModel' model
     3- cacheResponse:  If the file was already avalable on the cache, and aslso client wants to get cache result, it will send it as 'UploadImageModel' model
     */
    public func getImage(getImageInput: GetImageRequestModel,
                         uniqueId:      @escaping (String) -> (),
                         progress:      @escaping (Float) -> (),
                         completion:    @escaping (Data?, UploadImageModel) -> (),
                         cacheResponse: @escaping (UploadImageModel, String) -> ()) {
        
        let theUniqueId = generateUUID()
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        var parameters: Parameters = ["hashCode": getImageInput.hashCode,
                                      "imageId": getImageInput.imageId]
        if let theActual = getImageInput.actual {
            parameters["actual"] = JSON(theActual)
        }
        if let theDownloadable = getImageInput.downloadable {
            parameters["downloadable"] = JSON(theDownloadable)
        }
        if let theHeight = getImageInput.height {
            parameters["height"] = JSON(theHeight)
        }
        if let theWidth = getImageInput.width {
            parameters["width"] = JSON(theWidth)
        }
        
        uniqueId(theUniqueId)
        
        // if cache is enabled by user, first return cache result to the user
        if enableCache {
            if let (cacheImageResult, imagePath) = Chat.cacheDB.retrieveUploadImage(hashCode: getImageInput.hashCode, imageId: getImageInput.imageId) {
                cacheResponse(cacheImageResult, imagePath)
            }
        }
        
        
        // IMPROVMENT NEEDED:
        // maybe if i had the answer from cache, i have to ignore the bottom code that request to server to get file again!!
        // so this code have to only request file if it couldn't find the file on the cache
        httpRequest(from: url, withMethod: method, withHeaders: nil, withParameters: parameters, dataToSend: nil, requestUniqueId: nil, isImage: nil, isFile: nil, completion: { _ in }, progress: { (myProgress) in
            progress(myProgress)
        }, idDownloadRequest: true, isMapServiceRequst: false) { (imageDataResponse, responseHeader)  in
            
            if let myData = imageDataResponse {
                // save data comes from server to the Cache
                let fileName = responseHeader["name"].string
                let fileType = responseHeader["type"].string
                let theFinalFileName = "\(fileName ?? "default").\(fileType ?? "none")"
                let uploadImage = UploadImage(actualHeight: nil, actualWidth: nil, hashCode: getImageInput.hashCode, height: getImageInput.height, id: getImageInput.imageId, name: theFinalFileName, width: getImageInput.width)
                Chat.cacheDB.saveUploadImage(imageInfo: uploadImage, imageData: myData)
                
                let uploadImageModel = UploadImageModel(messageContentModel: uploadImage, errorCode: 0, errorMessage: "", hasError: false)
                completion(myData, uploadImageModel)
            } else {
                let hasError = responseHeader["hasError"].bool ?? false
                let errorMessage = responseHeader["errorMessage"].string ?? ""
                let errorCode = responseHeader["errorCode"].int ?? 999
                let errorUploadImageModel = UploadImageModel(messageContentModel: nil, errorCode: errorCode, errorMessage: errorMessage, hasError: hasError)
                completion(nil, errorUploadImageModel)
            }
        }
        
    }
    
    
    /*
     GetFIle:
     get specific file.
     
     By calling this function, HTTP request of type (GET_FILE) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as 'GetFileRequestModel' Model which are:
     - downloadable:
     - fileId:
     - hashCode:
     
     + Outputs:
     It has 3 callbacks as response:
     1- progress:       The progress of the downloading file as a number between 0 and 1.   (Float)
     2- completion:     when the file completely downloaded, it will sent to client as 'UploadFileModel' model
     3- cacheResponse:  If the file was already avalable on the cache, and aslso client wants to get cache result, it will send it as 'UploadFileModel' model
     */
    public func getFile(getFileInput:   GetFileRequestModel,
                        uniqueId:       @escaping (String) -> (),
                        progress:       @escaping (Float) -> (),
                        completion:     @escaping (Data?, UploadFileModel) -> (),
                        cacheResponse:  @escaping (UploadFileModel, String) -> ()) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        var parameters: Parameters = ["hashCode": getFileInput.hashCode,
                                      "fileId": getFileInput.fileId]
        
        if let theDownloadable = getFileInput.downloadable {
            parameters["downloadable"] = JSON(theDownloadable)
        }
        
        
        // if cache is enabled by user, first return cache result to the user
        if enableCache {
            if let (cacheFileResult, imagePath) = Chat.cacheDB.retrieveUploadFile(fileId: getFileInput.fileId, hashCode: getFileInput.hashCode) {
                cacheResponse(cacheFileResult, imagePath)
            }
        }
        
        
        // IMPROVMENT NEEDED:
        // maybe if i had the answer from cache, i have to ignore the bottom code that request to server to get file again!!
        // so this code have to only request file if it couldn't find the file on the cache
        httpRequest(from: url, withMethod: method, withHeaders: nil, withParameters: parameters, dataToSend: nil, requestUniqueId: nil, isImage: nil, isFile: nil, completion: { _ in }, progress: { (myProgress) in
            progress(myProgress)
        }, idDownloadRequest: true, isMapServiceRequst: false) { (fileDataResponse, responseHeader) in
            
            if let myFile = fileDataResponse {
                // save data comes from server to the Cache
                let fileName = responseHeader["name"].string
                let fileType = responseHeader["type"].string
                let theFinalFileName = "\(fileName ?? "default").\(fileType ?? "none")"
                let uploadFile = UploadFile(hashCode: getFileInput.hashCode, id: getFileInput.fileId, name: theFinalFileName)
                Chat.cacheDB.saveUploadFile(fileInfo: uploadFile, fileData: myFile)
                
                let uploadFileModel = UploadFileModel(messageContentModel: uploadFile, errorCode: 0, errorMessage: "", hasError: false)
                
                completion(myFile, uploadFileModel)
            } else {
                let hasError = responseHeader["hasError"].bool ?? false
                let errorMessage = responseHeader["errorMessage"].string ?? ""
                let errorCode = responseHeader["errorCode"].int ?? 999
                let errorUploadFileModel = UploadFileModel(messageContentModel: nil, errorCode: errorCode, errorMessage: errorMessage, hasError: hasError)
                completion(nil, errorUploadFileModel)
            }
            
        }
        
    }
    
    
    
    
    public func manageUpload(image: Bool, file: Bool, withUniqueId: String, withAction action: DownloaUploadAction,
                             completion: @escaping (String, Bool) -> ()) {
        for (index, item) in uploadRequest.enumerated() {
            if item.uniqueId == withUniqueId {
                switch (action , image, file) {
                case (.suspend, _, _):
                    item.upload.suspend()
                    completion("upload image/file with this uniqueId: '\(withUniqueId)' had been Suspended", true)
                    
                case (.resume, _, _):
                    item.upload.resume()
                    completion("upload image/file with this uniqueId: '\(withUniqueId)' had been Resumed", true)
                    
                case (.cancel, true, false):
                    item.upload.cancel()
                    uploadRequest.remove(at: index)
                    Chat.cacheDB.deleteWaitUploadImages(uniqueId: withUniqueId)
                    completion("upload image with this uniqueId: '\(withUniqueId)' had been Canceled", true)
                    
                case (.cancel, false, true):
                    item.upload.cancel()
                    uploadRequest.remove(at: index)
                    Chat.cacheDB.deleteWaitUploadFiles(uniqueId: withUniqueId)
                    completion("upload file with this uniqueId: '\(withUniqueId)' had been Canceled", true)
                    
                default:
                    completion("Wrong situation to manage upload", false)
                }
            }
        }
    }
    
    
    public func manageDownload(withUniqueId: String, withAction action: DownloaUploadAction,
                               completion: @escaping (String, Bool) -> ()) {
        for (index, item) in downloadRequest.enumerated() {
            if item.uniqueId == withUniqueId {
                switch action {
                case .cancel:
                    item.download.cancel()
                    completion("download with this uniqueId '\(withUniqueId)' had been Canceled", true)
                    
                case .suspend:
                    item.download.suspend()
                    completion("download with this uniqueId '\(withUniqueId)' had been Suspended", true)
                    
                case .resume:
                    item.download.resume()
                    completion("download with this uniqueId '\(withUniqueId)' had been Resumed", true)
                    
                }
                downloadRequest.remove(at: index)
            }
        }
    }
    
    
    
    // MARK: - Map Management
    
    /*
     Map Revers:
     get location details from client location.
     
     By calling this function, HTTP request of type (REVERSE to the MAP_ADDRESS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as 'MapReverseRequestModel' Model which are:
     - lat:
     - lng:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:       the unique id of this request, that returns as a collback to client. (String)
     2- completion:     the final response of this request will sent to the client as 'MapReverseModel' model
     */
    public func mapReverse(mapReverseInput: MapReverseRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.MAP_ADDRESS)\(SERVICES_PATH.REVERSE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        let headers:    HTTPHeaders = ["Api-Key": mapApiKey]
        let parameters: Parameters  = ["lat": mapReverseInput.lat,
                                       "lng": mapReverseInput.lng,
                                       "uniqueId": theUniqueId]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: parameters, dataToSend: nil, requestUniqueId: nil, isImage: nil, isFile: nil, completion: { (jsonResponse) in
            if let theResponse = jsonResponse as? JSON {
                let mapReverseModel = MapReverseModel(messageContent: theResponse, hasError: false, errorMessage: "", errorCode: 0)
                completion(mapReverseModel)
            }
            
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: true) { _,_ in }
        
        
    }
    
    
    /*
     Map Search:
     search near thing inside the map, whoes where close to the client location.
     
     By calling this function, HTTP request of type (SEARCH to the MAP_ADDRESS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as 'MapSearchRequestModel' Model which are:
     - lat:
     - lng:
     - term: the search term
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:       the unique id of this request, that returns as a collback to client. (String)
     2- completion:     the final response of this request will sent to the client as 'MapSearchModel' model
     */
    public func mapSearch(mapSearchInput:   MapSearchRequestModel,
                          uniqueId:         @escaping (String) -> (),
                          completion:       @escaping callbackTypeAlias) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.MAP_ADDRESS)\(SERVICES_PATH.SEARCH.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        let headers:    HTTPHeaders = ["Api-Key": mapApiKey]
        let parameters: Parameters  = ["lat":   mapSearchInput.lat,
                                       "lng":   mapSearchInput.lng,
                                       "term":  mapSearchInput.term]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: parameters, dataToSend: nil, requestUniqueId: nil, isImage: nil, isFile: nil, completion: { (jsonResponse) in
            
            if let theResponse = jsonResponse as? JSON {
                let mapSearchModel = MapSearchModel(messageContent: theResponse, hasError: false, errorMessage: "", errorCode: 0)
                completion(mapSearchModel)
            }
            
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: true) { _,_ in }
        
    }
    
    
    /*
     Map Routing:
     send 2 locations, and then give routing suggesston.
     
     By calling this function, HTTP request of type (SEARCH to the MAP_ADDRESS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as 'MapRoutingRequestModel' Model which are:
     - originLat:
     - originLng:
     - destinationLat:
     - destinationLng:
     - alternative:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:       the unique id of this request, that returns as a collback to client. (String)
     2- completion:     the final response of this request will sent to the client as 'MapRoutingModel' model
     */
    public func mapRouting(mapRoutingInput: MapRoutingRequestModel,
                           uniqueId:        @escaping (String) -> (),
                           completion:      @escaping callbackTypeAlias) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.MAP_ADDRESS)\(SERVICES_PATH.ROUTING.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        let headers:    HTTPHeaders = ["Api-Key": mapApiKey]
        let parameters: Parameters  = ["origin":        "\(mapRoutingInput.originLat),\(mapRoutingInput.originLng)",
            "destination":   "\(mapRoutingInput.destinationLat),\(mapRoutingInput.destinationLng)",
            "alternative":   mapRoutingInput.alternative]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: parameters, dataToSend: nil, requestUniqueId: nil, isImage: nil, isFile: nil, completion: { (jsonResponse) in
            if let theResponse = jsonResponse as? JSON {
                let mapRoutingModel = MapRoutingModel(messageContent: theResponse, hasError: false, errorMessage: "", errorCode: 0)
                completion(mapRoutingModel)
            }
            
        }, progress: nil, idDownloadRequest: false, isMapServiceRequst: true) { _,_ in }
        
    }
    
    
    /*
     Map Static Image:
     get a static image from the map based on the location that user wants.
     
     By calling this function, HTTP request of type (STATIC_IMAGE to the MAP_ADDRESS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as 'MapStaticImageRequestModel' Model which are:
     - type:
     - zoom:
     - centerLat:
     - centerLng:
     - width:
     - height:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:       the unique id of this request, that returns as a collback to client. (String)
     2- completion:     the final response of this request will sent to the client as and Image file
     */
    public func mapStaticImage(mapStaticImageInput: MapStaticImageRequestModel,
                               uniqueId:            @escaping (String) -> (),
                               progress:            @escaping (Float) -> (),
                               completion:          @escaping callbackTypeAlias) {
        
        let theUniqueId = generateUUID()
        uniqueId(theUniqueId)
        
        let url = "\(SERVICE_ADDRESSES.MAP_ADDRESS)\(SERVICES_PATH.STATIC_IMAGE.rawValue)"
        let method:     HTTPMethod  = HTTPMethod.get
        let parameters: Parameters  = ["key":       mapApiKey,
                                       "type":      mapStaticImageInput.type,
                                       "zoom":      mapStaticImageInput.zoom,
                                       "center":    "\(mapStaticImageInput.centerLat),\(mapStaticImageInput.centerLng)",
            "width":     mapStaticImageInput.width,
            "height":    mapStaticImageInput.height]
        
        Alamofire.request(url, method: method, parameters: parameters, headers: nil).downloadProgress(closure: { (downloadProgress) in
            print("downloadProgress = \(downloadProgress)")
            let myProgressFloat: Float = Float(downloadProgress.fractionCompleted)
            progress(myProgressFloat)
        }).responseData { (myResponse) in
            
            if myResponse.result.isSuccess {
                
                guard let image = myResponse.result.value else { print("Value is empty!!!"); return }
                completion(image)

            } else {
                print("Failed!")
            }
            
        }
        
    }
    
    
    
    
    public func sendLocationMessage(sendLocationMessageRequest: SendLocationMessageRequestModel,
                                    uniqueId:                   @escaping (String) -> (),
                                    downloadProgress:           @escaping (Float) -> (),
                                    uploadProgress:             @escaping (Float) -> (),
                                    onSent:                     @escaping callbackTypeAlias,
                                    onDelivere:                 @escaping callbackTypeAlias,
                                    onSeen:                     @escaping callbackTypeAlias) {
        
        let mapStaticImageInput = MapStaticImageRequestModel(centerLat: sendLocationMessageRequest.mapStaticCenterLat,
                                                             centerLng: sendLocationMessageRequest.mapStaticCenterLng,
                                                             height:    sendLocationMessageRequest.mapStaticHeight,
                                                             type:      sendLocationMessageRequest.mapStaticType,
                                                             width:     sendLocationMessageRequest.mapStaticWidth,
                                                             zoom:      sendLocationMessageRequest.mapStaticZoom)
        
        mapStaticImage(mapStaticImageInput: mapStaticImageInput, uniqueId: { _ in }, progress: { (myProgress) in
            downloadProgress(myProgress)
        }) { (imageData) in
            let fileMessageInput = SendFileMessageRequestModel(fileName: nil,
                                                               imageName:   sendLocationMessageRequest.sendMessageImageName,
                                                               xC:          sendLocationMessageRequest.sendMessageXC,
                                                               yC:          sendLocationMessageRequest.sendMessageYC,
                                                               hC:          sendLocationMessageRequest.sendMessageHC,
                                                               wC:          sendLocationMessageRequest.sendMessageWC,
                                                               threadId:    sendLocationMessageRequest.sendMessageThreadId,
                                                               content:     sendLocationMessageRequest.sendMessageContent,
                                                               metaData:    sendLocationMessageRequest.sendMessageMetaData,
                                                               repliedTo:   sendLocationMessageRequest.sendMessageRepliedTo,
                                                               subjectId:   sendLocationMessageRequest.sendMessageSubjectId,
                                                               typeCode:    sendLocationMessageRequest.sendMessageTypeCode,
                                                               fileToSend:  nil,
                                                               imageToSend: (imageData as! Data))
            sendTM(params: fileMessageInput)
        }
        
        func sendTM(params: SendFileMessageRequestModel) {
            sendFileMessage(sendFileMessageInput: params, uniqueId: { (requestUniqueId) in
                uniqueId(requestUniqueId)
            }, uploadProgress: { (myProgress) in
                uploadProgress(myProgress)
            }, onSent: { (sent) in
                onSent(sent)
            }, onDelivered: { (deliver) in
                onDelivere(deliver)
            }) { (seen) in
                onSeen(seen)
            }
        }
        
    }
    
    
    // MARK: -
    
    /*
     UpdateThreadInfo:
     update information about a thread.
     
     By calling this function, a request of type 30 (UPDATE_THREAD_INFO) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:
     - image:
     - description:
     - title:
     - metadata:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func updateThreadInfo(updateThreadInfoInput: UpdateThreadInfoRequestModel,
                                 uniqueId:              @escaping (String) -> (),
                                 completion:            @escaping callbackTypeAlias) {
        log.verbose("Try to request to update thread info with this parameters: \n \(updateThreadInfoInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UPDATE_THREAD_INFO.rawValue,
                                       "typeCode": updateThreadInfoInput.typeCode ?? generalTypeCode]
        
        if let threadId = updateThreadInfoInput.subjectId {
            sendMessageParams["threadId"] = JSON(threadId)
            sendMessageParams["subjectId"] = JSON(threadId)
            
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "Thread ID is required for Updating thread info!", errorResult: nil)
        }
        
        var content: JSON = [:]
        
        if let image = updateThreadInfoInput.image {
            content["image"] = JSON(image)
        }
        
        if let description = updateThreadInfoInput.description {
            content["description"] = JSON(description)
        }
        
        if let name = updateThreadInfoInput.title {
            content["name"] = JSON(name)
        }
        
        if let metadata = updateThreadInfoInput.metadata {
            let metadataStr = "\(metadata)"
            content["metadata"] = JSON(metadataStr)
        }
        
        sendMessageParams["content"] = JSON("\(content)")
        
        sendMessageWithCallback(params: sendMessageParams, callback: UpdateThreadInfoCallback(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (updateThreadInfoUniqueId) in
            uniqueId(updateThreadInfoUniqueId)
        }
        updateThreadInfoCallbackToUser = completion
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'UpdateThreadInfoRequestModel' to get the parameters, it'll use JSON
    public func updateThreadInfo(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to update thread info with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UPDATE_THREAD_INFO.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode]
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["threadId"] = JSON(threadId)
            sendMessageParams["subjectId"] = JSON(threadId)
            
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "Thread ID is required for Updating thread info!", errorResult: nil)
        }
        
        var content: JSON = [:]
        
        if let image = params["image"].string {
            content["image"] = JSON(image)
        }
        
        if let description = params["description"].string {
            content["description"] = JSON(description)
        }
        
        if let name = params["title"].string {
            content["name"] = JSON(name)
        }
        
        if let metadata = params["metadata"].string {
            content["metadata"] = JSON(metadata)
        } else if (params["metadata"] != JSON.null) {
            let metadata = params["metadata"]
            let metadataStr = "\(metadata)"
            content["metadata"] = JSON(metadataStr)
        }
        
        sendMessageParams["content"] = JSON("\(content)")
        
        sendMessageWithCallback(params: sendMessageParams, callback: UpdateThreadInfoCallback(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (updateThreadInfoUniqueId) in
            uniqueId(updateThreadInfoUniqueId)
        }
        updateThreadInfoCallbackToUser = completion
    }
    
    
    /*
     SpamPVThread:
     spam a thread.
     
     By calling this function, a request of type 41 (SPAM_PV_THREAD) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func spamPvThread(spamPvThreadInput: SpamPvThreadRequestModel,
                             uniqueId:          @escaping (String) -> (),
                             completion:        @escaping callbackTypeAlias) {
        log.verbose("Try to request to spam thread with this parameters: \n \(spamPvThreadInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.SPAM_PV_THREAD.rawValue,
                                       "typeCode": spamPvThreadInput.typeCode ?? generalTypeCode]
        
        if let subjectId = spamPvThreadInput.threadId {
            sendMessageParams["subjectId"] = JSON(subjectId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: SpamPvThread(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (spamUniqueId) in
            uniqueId(spamUniqueId)
        }
        spamPvThreadCallbackToUser = completion
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'SpamPvThreadRequestModel' to get the parameters, it'll use JSON
    public func spamPvThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to spam thread with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.SPAM_PV_THREAD.rawValue,
                                       "typeCode": params["typeCode"].string ?? generalTypeCode]
        
        if let subjectId = params["threadId"].int {
            sendMessageParams["subjectId"] = JSON(subjectId)
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: SpamPvThread(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (spamUniqueId) in
            uniqueId(spamUniqueId)
        }
        spamPvThreadCallbackToUser = completion
    }
    
    
    /*
     MessageDeliveryList:
     list of participants that send deliver for some message id.
     
     By calling this function, a request of type 32 (GET_MESSAGE_DELEVERY_PARTICIPANTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func messageDeliveryList(messageDeliveryListInput:   MessageDeliverySeenListRequestModel,
                                    uniqueId:                   @escaping (String) -> (),
                                    completion:                 @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message deliver participants with this parameters: \n \(messageDeliveryListInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.rawValue,
                                       "typeCode": messageDeliveryListInput.typeCode ?? generalTypeCode]
        
        var content: JSON = [:]
        if let count = messageDeliveryListInput.count {
            content["count"] = JSON(count)
        }
        if let offset = messageDeliveryListInput.offset {
            content["offset"] = JSON(offset)
        }
        
//        content["typeCode"] = JSON(messageDeliveryListInput.typeCode ?? generalTypeCode)
        
        content["messageId"] = JSON(messageDeliveryListInput.messageId)
        
        sendMessageParams["content"] = content
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetMessageDeliverList(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (messageDeliverListUniqueId) in
            uniqueId(messageDeliverListUniqueId)
        }
        getMessageDeliverListCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'MessageDeliverySeenListRequestModel' to get the parameters, it'll use JSON
    public func messageDeliveryList(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message deliver participants with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_MESSAGE_DELEVERY_PARTICIPANTS.rawValue]
        
        var content: JSON = ["count": 50, "offset": 0]
        
        if let count = params["count"].int {
            if count > 0 {
                content["count"] = JSON(count)
            }
        }
        
        if let offset = params["offset"].int {
            if offset > 0 {
                content["offset"] = JSON(offset)
            }
        }
        
        if let typeCode = params["typeCode"].string {
            sendMessageParams["typeCode"] = JSON(typeCode)
        } else {
            sendMessageParams["typeCode"] = JSON(generalTypeCode)
        }
        
        //        if let subjectId = params["subjectId"].int {
        //            sendMessageParams["threadId"] = JSON(subjectId)
        //        }
        
        if let messageId = params["messageId"].int {
            content["messageId"] = JSON(messageId)
        }
        
        sendMessageParams["content"] = content
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetMessageDeliverList(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (messageDeliverListUniqueId) in
            uniqueId(messageDeliverListUniqueId)
        }
        getMessageDeliverListCallbackToUser = completion
    }
    
    
    /*
     MessageSeenList:
     list of participants that send seen for some message id.
     
     By calling this function, a request of type 33 (GET_MESSAGE_SEEN_PARTICIPANTS) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - subjectId:
     - typeCode:
     
     + Outputs:
     It has 2 callbacks as response:
     1- uniqueId:    it will returns the request 'UniqueId' that will send to server.        (String)
     2- completion:
     */
    public func messageSeenList(messageSeenListInput:   MessageDeliverySeenListRequestModel,
                                uniqueId:               @escaping (String) -> (),
                                completion:             @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message seen participants with this parameters: \n \(messageSeenListInput)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.rawValue]
        
        var content: JSON = [:]
        content["count"] = JSON(messageSeenListInput.count ?? 50)
        content["offset"] = JSON(messageSeenListInput.offset ?? 0)
        content["typeCode"] = JSON(messageSeenListInput.typeCode ?? generalTypeCode)
        
        content["messageId"] = JSON(messageSeenListInput.messageId)
        
        sendMessageParams["content"] = content
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetMessageSeenList(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (messageSeenListUniqueId) in
            uniqueId(messageSeenListUniqueId)
        }
        getMessageSeenListCallbackToUser = completion
        
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'MessageDeliverySeenListRequestModel' to get the parameters, it'll use JSON
    public func messageSeenList(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        log.verbose("Try to request to get message seen participants with this parameters: \n \(params)", context: "Chat")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_MESSAGE_SEEN_PARTICIPANTS.rawValue]
        
        var content: JSON = ["count": 50, "offset": 0]
        
        if let count = params["count"].int {
            if count > 0 {
                content["count"] = JSON(count)
            }
        }
        
        if let offset = params["offset"].int {
            if offset > 0 {
                content["offset"] = JSON(offset)
            }
        }
        
        if let typeCode = params["typeCode"].string {
            sendMessageParams["typeCode"] = JSON(typeCode)
        } else {
            sendMessageParams["typeCode"] = JSON(generalTypeCode)
        }
        
        if let messageId = params["messageId"].int {
            content["messageId"] = JSON(messageId)
        }
        
        sendMessageParams["content"] = content
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetMessageSeenList(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (messageSeenListUniqueId) in
            uniqueId(messageSeenListUniqueId)
        }
        getMessageSeenListCallbackToUser = completion
        
    }
    
    
    /*
     Deliver:
     send deliver for some message.
     
     By calling this function, a request of type 4 (DELIVERY) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - messageId:
     - ownerId:
     - typeCode:
     
     + Outputs:
     this function has no output!
     */
    public func deliver(deliverInput: DeliverSeenRequestModel) {
        log.verbose("Try to send deliver message for a message id with this parameters: \n \(deliverInput)", context: "Chat")
        
        if let theUserInfo = userInfo {
            let userInfoJSON = theUserInfo.formatToJSON()
            if (deliverInput.ownerId != userInfoJSON["id"].intValue) {
                let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELIVERY.rawValue,
                                               "content":           deliverInput.messageId,
                                               "typeCode":          deliverInput.typeCode ?? generalTypeCode,
                                               "pushMsgType":       3]
                sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: nil, deliverCallback: nil, seenCallback: nil, uniuqueIdCallback: nil)
            }
        }
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'DeliverSeenRequestModel' to get the parameters, it'll use JSON
    public func deliver(params: JSON) {
        log.verbose("Try to send deliver message for a message id with this parameters: \n \(params)", context: "Chat")
        
        if let theUserInfo = userInfo {
            let userInfoJSON = theUserInfo.formatToJSON()
            if (params["ownerId"].intValue != userInfoJSON["id"].intValue) {
                let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELIVERY.rawValue,
                                               "content":           params["messageId"].intValue,
                                               "typeCode":          params["typeCode"].int ?? generalTypeCode,
                                               "pushMsgType":       3]
                sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: nil, deliverCallback: nil, seenCallback: nil, uniuqueIdCallback: nil)
            }
        }
    }
    
    
    /*
     Seen:
     send seen for some message.
     
     By calling this function, a request of type 5 (SEEN) will send throut Chat-SDK,
     then the response will come back as callbacks to client whose calls this function.
     
     + Inputs:
     this function will get some optional prameters as an input, as JSON or Model (depends on the function that you would use) which are:
     - messageId:
     - ownerId:
     - typeCode:
     
     + Outputs:
     this function has no output!
     */
    public func seen(seenInput: DeliverSeenRequestModel) {
        log.verbose("Try to send deliver message for a message id with this parameters: \n \(seenInput)", context: "Chat")
        
        if let theUserInfo = userInfo {
            let userInfoJSON = theUserInfo.formatToJSON()
            if (seenInput.ownerId != userInfoJSON["id"].intValue) {
                let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.SEEN.rawValue,
                                               "content":           seenInput.messageId,
                                               "typeCode":          seenInput.typeCode ?? generalTypeCode,
                                               "pushMsgType":       3]
                sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: nil, deliverCallback: nil, seenCallback: nil, uniuqueIdCallback: nil)
            }
        }
    }
    
    // NOTE: This method will be deprecate soon
    // this method will do the same as tha funciton above but instead of using 'DeliverSeenRequestModel' to get the parameters, it'll use JSON
    public func seen(params: JSON) {
        log.verbose("Try to send deliver message for a message id with this parameters: \n \(params)", context: "Chat")
        
        if let theUserInfo = userInfo {
            let userInfoJSON = theUserInfo.formatToJSON()
            if (params["ownerId"].intValue != userInfoJSON["id"].intValue) {
                let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.SEEN.rawValue,
                                               "content":           params["messageId"].intValue,
                                               "typeCode":          params["typeCode"].string ?? generalTypeCode,
                                               "pushMsgType":       3]
                sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: nil, deliverCallback: nil, seenCallback: nil, uniuqueIdCallback: nil)
            }
        }
    }
    
    
    // this function will generate a UUID to use in your request if needed (specially for uniqueId)
    // and it will return the UUID as String
    public func generateUUID() -> String {
        let myUUID = NSUUID().uuidString
        return myUUID
    }
    
    
    // log out from async
    public func logOut() {
        asyncClient?.asyncLogOut()
    }
    
    // this function will return Chate State as JSON
    public func getChatState() -> JSON {
        return chatFullStateObject
    }
    
    // if your socket connection is disconnected you can reconnect it by calling this function
    public func reconnect() {
        asyncClient?.asyncReconnectSocket()
    }
    
    // this function will get a String and it will put it on 'token' variable, to use on your requests!
    public func setToken(newToken: String) {
        token = newToken
    }
    
    
}


// Calbacks Classes
extension Chat {
    
    func chatDelegateUserInfo(userInfo: JSON) {

        let hasError = userInfo["hasError"].boolValue
        let errorMessage = userInfo["errorMessage"].stringValue
        let errorCode = userInfo["errorCode"].intValue

        if (!hasError) {
            let resultData = userInfo["result"]
            
            // save data comes from server to the Cache
            let user = User(messageContent: resultData)
            Chat.cacheDB.createUserInfoObject(user: user)

            let userInfoModel = UserInfoModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
            delegate?.userEvents(type: UserEventTypes.userInfo, result: userInfoModel)
        }
    }
    private class UserInfoCallback: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("UserInfoCallback", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let resultData = response["result"]
                
//                // save data comes from server to the Cache
//                let user = User(messageContent: resultData)
//                Chat.cacheDB.createUserInfoObject(user: user)
                
                let userInfoModel = UserInfoModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(userInfoModel)
            } else {
                failure(["result": false])
            }
            
        }
    }
    
    func chatDelegateGetContacts(getContact: JSON) {
        var returnData: JSON = [:]
        
        let hasError = getContact["hasError"].boolValue
        let errorMessage = getContact["errorMessage"].stringValue
        let errorCode = getContact["errorCode"].intValue
        
        returnData["hasError"] = JSON(hasError)
        returnData["errorMessage"] = JSON(errorMessage)
        returnData["errorCode"] = JSON(errorCode)
        
        if (!hasError) {
            let result = getContact["result"]
            let count = result["contentCount"].intValue
            let offset = result["nextOffset"].intValue
            
            let messageContent: [JSON] = getContact["result"].arrayValue
            let contentCount = getContact["contentCount"].intValue
            
            // save data comes from server to the Cache
            var contacts = [Contact]()
            for item in messageContent {
                let myContact = Contact(messageContent: item)
                contacts.append(myContact)
            }
            Chat.cacheDB.saveContactObjects(contacts: contacts)
            
            let getContactsModel = GetContactsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset - count, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
            delegate?.contactEvents(type: ContactEventTypes.getContact, result: getContactsModel)
        }
    }
    private class GetContactsCallback: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetContactsCallback", context: "Chat")
            
            var returnData: JSON = [:]
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            returnData["hasError"] = JSON(hasError)
            returnData["errorMessage"] = JSON(errorMessage)
            returnData["errorCode"] = JSON(errorCode)
            
            if (!hasError) {
                let content = sendParams["content"]
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
//                // save data comes from server to the Cache
//                var contacts = [Contact]()
//                for item in messageContent {
//                    let myContact = Contact(messageContent: item)
//                    contacts.append(myContact)
//                }
//                Chat.cacheDB.saveContactObjects(contacts: contacts)
                
                let getContactsModel = GetContactsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getContactsModel)
            }
        }
    }
    
    
    func chatDelegateGetThread(getThread: JSON) {
        let hasError = getThread["hasError"].boolValue
        let errorMessage = getThread["errorMessage"].stringValue
        let errorCode = getThread["errorCode"].intValue
        
        if (!hasError) {
            let result = getThread["result"]
            let count = result["contentCount"].intValue
            let offset = result["nextOffset"].intValue
            
            let messageContent: [JSON] = getThread["result"].arrayValue
            let contentCount = getThread["contentCount"].intValue
            
            // save data comes from server to the Cache
            var conversations = [Conversation]()
            for item in messageContent {
                let myConversation = Conversation(messageContent: item)
                conversations.append(myConversation)
            }
            Chat.cacheDB.saveThreadObjects(threads: conversations)
            
            let getThreadsModel = GetThreadsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset - count, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
            delegate?.threadEvents(type: ThreadEventTypes.getThreads, result: getThreadsModel)
        }
    }
    private class GetThreadsCallbacks: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetThreadsCallbacks", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let content = sendParams["content"]
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
//                // save data comes from server to the Cache
//                var conversations = [Conversation]()
//                for item in messageContent {
//                    let myConversation = Conversation(messageContent: item)
//                    conversations.append(myConversation)
//                }
//                Chat.cacheDB.saveThreadObjects(threads: conversations)
                
                let getThreadsModel = GetThreadsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getThreadsModel)
            }
        }
        
    }
    
    
    func chatDelegateGetHistory(getHistory: JSON) {
        let hasError = getHistory["hasError"].boolValue
        let errorMessage = getHistory["errorMessage"].stringValue
        let errorCode = getHistory["errorCode"].intValue
        
        if (!hasError) {
            let result = getHistory["result"]
            let count = result["contentCount"].intValue
            let offset = result["nextOffset"].intValue
            
            let messageContent: [JSON] = getHistory["result"].arrayValue
            let contentCount = getHistory["contentCount"].intValue
            
//            // save data comes from server to the Cache
//            var messages = [Message]()
//            for item in messageContent {
//                let myMessage = Message(threadId: sendParams["subjectId"].intValue, pushMessageVO: item)
//                messages.append(myMessage)
//            }
//            Chat.cacheDB.saveMessageObjects(messages: messages, getHistoryParams: sendParams)
            
            let getHistoryModel = GetHistoryModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset - count, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
            delegate?.threadEvents(type: ThreadEventTypes.getHistory, result: getHistoryModel)
        }
    }
    private class GetHistoryCallbacks: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetHistoryCallbacks", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let content = sendParams["content"]
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                // save data comes from server to the Cache
                var messages = [Message]()
                for item in messageContent {
                    let myMessage = Message(threadId: sendParams["subjectId"].intValue, pushMessageVO: item)
                    messages.append(myMessage)
                }
                Chat.cacheDB.saveMessageObjects(messages: messages, getHistoryParams: sendParams)
                
                let getHistoryModel = GetHistoryModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getHistoryModel)
            }
        }
    }
    
    
    func chatDelegateGetParticipants(getParticipants: JSON) {
        let hasError = getParticipants["hasError"].boolValue
        let errorMessage = getParticipants["errorMessage"].stringValue
        let errorCode = getParticipants["errorCode"].intValue
        
        if (!hasError) {
            let result = getParticipants["result"]
            let count = result["contentCount"].intValue
            let offset = result["nextOffset"].intValue
            
            let messageContent: [JSON] = getParticipants["result"].arrayValue
            let contentCount = getParticipants["contentCount"].intValue
            
//            var participants = [Participant]()
//            for item in messageContent {
//                let myParticipant = Participant(messageContent: item, threadId: sendParams["subjectId"].intValue)
//                participants.append(myParticipant)
//            }
//            Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: sendParams["subjectId"].intValue, withParticipants: participants)
            
            let getThreadParticipantsModel = GetThreadParticipantsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset - count, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
            delegate?.threadEvents(type: ThreadEventTypes.getThreadParticipants, result: getThreadParticipantsModel)
        }
    }
    private class GetThreadParticipantsCallbacks: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("GetThreadParticipantsCallbacks", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let content = sendParams["content"]
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                
                // save data comes from server to the Cache, in the Back Thread
                //                DispatchQueue.global().async {
                
                var participants = [Participant]()
                for item in messageContent {
                    let myParticipant = Participant(messageContent: item, threadId: sendParams["subjectId"].intValue)
                    participants.append(myParticipant)
                }
                Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: sendParams["subjectId"].intValue, withParticipants: participants)
                //                }
                
                let getThreadParticipantsModel = GetThreadParticipantsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getThreadParticipantsModel)
            }
        }
    }
    
    
    func chatDelegateCreateThread(createThread: JSON) {
        let hasError = createThread["hasError"].boolValue
        let errorMessage = createThread["errorMessage"].stringValue
        let errorCode = createThread["errorCode"].intValue
        
        if (!hasError) {
            let resultData: JSON = createThread["result"]
            
            let createThreadModel = CreateThreadModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
            delegate?.threadEvents(type: ThreadEventTypes.new, result: createThreadModel)
        }
    }
    private class CreateThreadCallback: CallbackProtocol {
        var mySendMessageParams: JSON
        init(parameters: JSON) {
            self.mySendMessageParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("CreateThreadCallback", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let resultData: JSON = response["result"]
                let createThreadModel = CreateThreadModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(createThreadModel)
                
            }
        }
        
    }
    
    
    func chatDelegateUpdateThreadInfo(threadInfo: JSON) {
        delegate?.threadEvents(type: ThreadEventTypes.UpdateThreadInfo, result: threadInfo)
    }
    private class UpdateThreadInfoCallback: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("UpdateThreadInfoCallback", context: "Chat")
            success(response)
        }
        
    }
    
    
    func chatDelegateAddParticipants(addParticipant: JSON) {
        let hasError = addParticipant["hasError"].boolValue
        let errorMessage = addParticipant["errorMessage"].stringValue
        let errorCode = addParticipant["errorCode"].intValue
        
        if (!hasError) {
            let messageContent = addParticipant["result"]
            
//            var participants = [Participant]()
//            for item in messageContent["participants"].arrayValue {
//                let myParticipant = Participant(messageContent: item, threadId: messageContent["id"].intValue)
//                participants.append(myParticipant)
//            }
//            Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: sendParams["subjectId"].intValue, withParticipants: participants)
            
            let addParticipantModel = AddParticipantModel(messageContent: messageContent, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
            delegate?.threadEvents(type: ThreadEventTypes.addParticipant, result: addParticipantModel)
        }
    }
    private class AddParticipantsCallback: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("AddParticipantsCallback", context: "Chat")
            /*
             * + AddParticipantsRequest   {object}
             *    - subjectId             {long}
             *    + content               {list} List of CONTACT IDs
             *       -id                  {long}
             *    - uniqueId              {string}
             */
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let messageContent = response["result"]
                
                var participants = [Participant]()
                for item in messageContent["participants"].arrayValue {
                    let myParticipant = Participant(messageContent: item, threadId: messageContent["id"].intValue)
                    participants.append(myParticipant)
                }
                Chat.cacheDB.saveThreadParticipantObjects(whereThreadIdIs: sendParams["subjectId"].intValue, withParticipants: participants)
                
                let addParticipantModel = AddParticipantModel(messageContent: messageContent, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                success(addParticipantModel)
            }
        }
    }
    
    
    func chatDelegateRemoveParticipants(removeParticipants: JSON) {
        let hasError = removeParticipants["hasError"].boolValue
        let errorMessage = removeParticipants["errorMessage"].stringValue
        let errorCode = removeParticipants["errorCode"].intValue
        
        if (!hasError) {
            
            let removeParticipantResult = removeParticipants["result"].arrayValue
            
            var removeParticipantsArray = [Participant]()
            for item in removeParticipantResult {
                let myParticipant = Participant(messageContent: item, threadId: item["thread"]["id"].int)
                Chat.cacheDB.deleteParticipant(inThread: item["thread"]["id"].intValue, withParticipantIds: [myParticipant.id!])

                removeParticipantsArray.append(myParticipant)
            }
            
            let removeParticipantModel = RemoveParticipantModel(messageObjects: removeParticipantsArray, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
            
            delegate?.threadEvents(type: ThreadEventTypes.removeParticipant, result: removeParticipantModel)
        }
    }
    private class RemoveParticipantsCallback: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("RemoveParticipantsCallback", context: "Chat")
            /*
             * + RemoveParticipantsRequest    {object}
             *    - subjectId                 {long}
             *    + content                   {list} List of PARTICIPANT IDs from Thread's Participants object
             *       -id                      {long}
             *    - uniqueId                  {string}
             */
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                
                let removeParticipantResult = response["result"].arrayValue
                
                var removeParticipantsArray = [Participant]()
                for item in removeParticipantResult {
                    let myParticipant = Participant(messageContent: item, threadId: sendParams["subjectId"].int)
//                    Chat.cacheDB.deleteParticipant(inThread: sendParams["subjectId"].intValue, withParticipantIds: [myParticipant.id!])
                    
                    removeParticipantsArray.append(myParticipant)
                }
                
                let removeParticipantModel = RemoveParticipantModel(messageObjects: removeParticipantsArray, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                success(removeParticipantModel)
            }
        }
    }
    
    
    private class SendMessageCallbacks: CallbackProtocolWith3Calls {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onSent(uID: String, response: JSON, success: @escaping callbackTypeAlias) {
            //
            
            // save this Message on the cache
            // first check if the sendParams threadId is the same as threadId of the Server response, then we will update the cache
            // there is an exeption: when we create thread an send message simultanusly, at first we don't have the threadId, to in this situation we have nothing as threadId in the sendParams, so we get the respose subjectId and save the response on the cache
            if (sendParams["subjectId"].int == response["subjectId"].int) || (sendParams["isCreateThreadAndSendMessage"].bool == true) {
                let msg = sendParams["content"].stringValue
                let strWithReturn = msg.replacingOccurrences(of: "Ⓝ", with: "\n")
                let strWithSpace = strWithReturn.replacingOccurrences(of: "Ⓢ", with: " ")
                let messageContent = strWithSpace.replacingOccurrences(of: "Ⓣ", with: "\t")
                
                let message = Message(threadId: response["subjectId"].int, pushMessageVO: response)
                //                let message = Message(threadId:     response["subjectId"].intValue,
                //                                      delivered:    response["delivered"].bool,
                //                                      editable:     response["editable"].bool,
                //                                      edited:       nil,
                //                                      id:           Int(response["content"].stringValue),
                //                                      message:      messageContent,
                //                                      messageType:  response["messageType"].string,
                //                                      metaData:     sendParams["metaData"].string,
                //                                      ownerId:      response["ownerId"].int,
                //                                      previousId:   nil,
                //                                      seen:         response["seen"].bool,
                //                                      time:         response["time"].int,
                //                                      uniqueId:     response["uniqueId"].stringValue,
                //                                      conversation: nil,
                //                                      forwardInfo:  nil,
                //                                      participant:  nil,
                //                                      replyInfo:    nil)
                message.message = messageContent
                message.metaData = sendParams["metaData"].string
                message.id = Int(response["content"].stringValue)
                
                Chat.cacheDB.saveMessageObjects(messages: [message], getHistoryParams: nil)
                
                // the response from server is come correctly, so this message will be removed from wait queue
                if let uID = message.uniqueId {
                    Chat.cacheDB.deleteWaitTextMessage(uniqueId: uID)
                    Chat.cacheDB.deleteWaitFileMessage(uniqueId: uID)
                    Chat.cacheDB.deleteWaitForwardMessage(uniqueId: uID)
                }
            }
            
            success(response)
        }
        
        func onDeliver(uID: String, response: JSON, success: @escaping callbackTypeAlias) {
            //
            success(response)
        }
        
        func onSeen(uID: String, response: JSON, success: @escaping callbackTypeAlias) {
            //
            success(response)
        }
        
    }
    
    
    private class EditMessageCallbacks: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("EditMessageCallbacks", context: "Chat")
            
            var returnData: JSON = [:]
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            returnData["hasError"] = JSON(hasError)
            returnData["errorMessage"] = JSON(errorMessage)
            returnData["errorCode"] = JSON(errorCode)
            
            if (!hasError) {
                let messageContent: JSON = response["result"]     // send contacts as json to user
                
                // save edited data on the cache
                let message = Message(threadId: sendParams["subjectId"].int, pushMessageVO: messageContent)
                Chat.cacheDB.saveMessageObjects(messages: [message], getHistoryParams: nil)
                
                // the response from server is come correctly, so this message will be removed from wait queue
                if let uID = message.uniqueId {
                    Chat.cacheDB.deleteWaitEditMessage(uniqueId: uID)
                }
                
                let resultData: JSON = ["editedMessage": messageContent]
                
                returnData["result"] = resultData
                success(returnData)
            }
        }
        
    }
    
    
    private class DeleteMessageCallbacks: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("DeleteMessageCallbacks", context: "Chat")
            
            var returnData: JSON = [:]
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            returnData["hasError"] = JSON(hasError)
            returnData["errorMessage"] = JSON(errorMessage)
            returnData["errorCode"] = JSON(errorCode)
            
            if (!hasError) {
                let messageContent: String = response["result"].stringValue     // send contacts as json to user
                //                let messageContentJSON: JSON = formatDataFromStringToJSON(stringCont: messageContent).convertStringContentToJSON() // send contacts as object to user
                //                let messageMessageObject = Message(threadId: nil, pushMessageVO: messageContentJSON)
                
                let deletedMessage: JSON = ["id": messageContent]
                let resultData: JSON = ["deletedMessage": deletedMessage]
                
                returnData["result"] = resultData
                
                
                Chat.cacheDB.deleteMessage(inThread: 1328, withMessageIds: [10799])
                
                success(returnData)
            }
        }
        
    }
    
    
    private class MuteThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("MuteThreadCallbacks", context: "Chat")
            
            success(response)
        }
        
    }
    
    
    private class UnmuteThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("UnmuteThreadCallbacks", context: "Chat")
            
            success(response)
        }
        
    }
    
    
    private class BlockContactCallbacks: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if response["result"] != JSON.null {
                let messageContent = response["result"]
                
                let blockUserModel = BlockedContactModel(messageContent: messageContent, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(blockUserModel)
            }
        }
    }
    
    
    private class UnblockContactCallbacks: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if response["result"] != JSON.null {
                let messageContent = response["result"]
                
                let unblockUserModel = BlockedContactModel(messageContent: messageContent, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(unblockUserModel)
            }
        }
    }
    
    
    private class GetBlockedContactsCallbacks: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let content = sendParams["content"]
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                let getBlockedModel = GetBlockedContactListModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getBlockedModel)
            }
            
        }
    }
    
    
    private class LeaveThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("LeaveThreadCallbacks", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let resultData: JSON = response["result"]
                
                let leaveThreadModel = CreateThreadModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(leaveThreadModel)
            }
        }
    }
    
    
    private class SpamPvThread: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("SpamPvThread", context: "Chat")
            
            success(response)
        }
    }
    
    
    
    private class GetMessageDeliverList: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let content = sendParams["content"]
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                let getBlockedModel = GetThreadParticipantsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getBlockedModel)
            }
            
        }
        
    }
    
    
    
    private class GetMessageSeenList: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let content = sendParams["content"]
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                let getBlockedModel = GetThreadParticipantsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getBlockedModel)
            }
            
        }
        
    }
    
    
    private class ClearHistoryCallback: CallbackProtocol {
        var mySendMessageParams: JSON
        init(parameters: JSON) {
            self.mySendMessageParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("ClearHistoryCallback", context: "Chat")
            
            let hasError = response["hasError"].boolValue
            
            if (!hasError) {
                success(response)
            }
        }
        
    }
    
}




















