//
//  Chat.swift
//  Chat
//
//  Created by Mahyar Zhiani on 5/21/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//


import Foundation
import Alamofire
import Async
import SwiftyJSON
import Contacts

public class Chat {
    public weak var delegate: ChatDelegates?
    
    var socketAddress: String   = ""
    var ssoHost: String         = ""        // SERVICE_ADDRESSES.SSO_ADDRESS
    var platformHost: String    = ""        // SERVICE_ADDRESSES.PLATFORM_ADDRESS
    var fileServer: String      = ""        // SERVICE_ADDRESSES.FILESERVER_ADDRESS
    var serverName: String      = ""
    var token: String           = ""
    //    var ssoGrantDevicesAddress = params.ssoGrantDevicesAddress
    var chatFullStateObject: JSON = [:]
    
    var msgPriority: Int
    var msgTTL: Int
    var httpRequestTimeout: Int
    var actualTimingLog: Bool
    
    var wsConnectionWaitTime: Double
    var connectionRetryInterval: Int
    var connectionCheckTimeout: Int
    var messageTtl: Int
    var reconnectOnClose: Bool
    
    var imageMimeTypes = ["image/bmp", "image/png", "image/tiff", "image/gif", "image/x-icon", "image/jpeg", "image/webp"]
    var imageExtentions = ["bmp", "png", "tiff", "tiff2", "gif", "ico", "jpg", "jpeg", "webp"]
    
    var asyncClient: Async?
    var deviceId: String?
    var peerId: Int?
    var oldPeerId: Int?
    var userInfo: JSON?
    
    var getHistoryCount: Int = 100
    var getUserInfoRetry = 5
    var getUserInfoRetryCount = 0
    var chatPingMessageInterval = 20
    var lastReceivedMessageTime: Date?
    var lastReceivedMessageTimeoutId: RepeatingTimer?
    var lastSentMessageTime: Date?
    var lastSentMessageTimeoutId: RepeatingTimer?
    var chatState = false
    
    var SERVICE_ADDRESSES = SERVICE_ADDRESSES_ENUM()
    
    public init(socketAddress: String, ssoHost: String, platformHost: String, fileServer: String, serverName: String, token: String, msgPriority: Int?, msgTTL: Int?, httpRequestTimeout: Int?, actualTimingLog: Bool?, wsConnectionWaitTime: Double, connectionRetryInterval: Int, connectionCheckTimeout: Int, messageTtl: Int, reconnectOnClose: Bool) {
        self.socketAddress = socketAddress
        self.ssoHost = ssoHost
        self.platformHost = platformHost
        self.fileServer = fileServer
        self.serverName = serverName
        self.token = token
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
        self.wsConnectionWaitTime = wsConnectionWaitTime
        self.connectionRetryInterval = connectionRetryInterval
        self.connectionCheckTimeout = connectionCheckTimeout
        self.messageTtl = messageTtl
        self.reconnectOnClose = reconnectOnClose
        
        self.SERVICE_ADDRESSES.SSO_ADDRESS          = ssoHost
        self.SERVICE_ADDRESSES.PLATFORM_ADDRESS     = platformHost
        self.SERVICE_ADDRESSES.FILESERVER_ADDRESS   = fileServer
        
        getDeviceIdWithToken { (deviceIdStr) in
            self.deviceId = deviceIdStr
            print("\n On Chat")
            print(":: get deviceId successfully = \(self.deviceId ?? "error!!") \n")
            DispatchQueue.main.async {
                self.CreateAsync()
            }
        }
        
    }
    
    
    public func CreateAsync() {
        if let dId = deviceId {
            asyncClient = Async(socketAddress: socketAddress, serverName: serverName, deviceId: dId, appId: nil, peerId: nil, messageTtl: messageTtl, connectionRetryInterval: connectionRetryInterval, reconnectOnClose: reconnectOnClose)
            asyncClient?.delegate = self
            asyncClient?.createSucket()
        }
    }
    
    static var map = [String: CallbackProtocol]()
    static var mapOnSent = [String: CallbackProtocolWith3Calls]()
    //    static var mapOnDeliver = [String: [[String: CallbackProtocolWith3Calls]]]()
    //                          [threadId: [[uniqueId: callback]]]
    static var mapOnDeliver = [String: [[String: CallbackProtocolWith3Calls]]]()
    static var mapOnSeen = [String: [[String: CallbackProtocolWith3Calls]]]()
    
    private var userInfoCallbackToUser: callbackTypeAlias?
    private var getContactsCallbackToUser: callbackTypeAlias?
    private var threadsCallbackToUser: callbackTypeAlias?
    private var historyCallbackToUser: callbackTypeAlias?
    private var threadParticipantsCallbackToUser: callbackTypeAlias?
    private var createThreadCallbackToUser: callbackTypeAlias?
    private var addParticipantsCallbackToUser: callbackTypeAlias?
    private var removeParticipantsCallbackToUser: callbackTypeAlias?
    private var sendCallbackToUserOnSent: callbackTypeAlias?
    private var sendCallbackToUserOnDeliver: callbackTypeAlias?
    private var sendCallbackToUserOnSeen: callbackTypeAlias?
    private var editMessageCallbackToUser: callbackTypeAlias?
    private var deleteMessageCallbackToUser: callbackTypeAlias?
    private var muteThreadCallbackToUser: callbackTypeAlias?
    private var unmuteThreadCallbackToUser: callbackTypeAlias?
    private var updateThreadInfoCallbackToUser: callbackTypeAlias?
    
    var tempSendMessageArr: [[String : JSON]] = []
    var tempReceiveMessageArr: [[String: JSON]] = []
    
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


// - MARK: Private Methods:
extension Chat {
    
    
    func getDeviceIdWithToken(completion: @escaping (String) -> ()) {
        let url = ssoHost + SERVICES_PATH.SSO_DEVICES.rawValue
        let method: HTTPMethod = .get
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: nil, dataToSend: nil, isImage: nil, isFile: nil, completion: { (myResponse) in
            let responseStr: String = myResponse as! String
            if let dataFromMsgString = responseStr.data(using: .utf8, allowLossyConversion: false) {
                // get currrent user deviceIdresponseStr
                do {
                    let msg = try JSON(data: dataFromMsgString)
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
                } catch {
                }
            }
        }, progress: nil)
        
    }
    
    
    func httpRequest(from urlStr: String, withMethod: HTTPMethod, withHeaders: HTTPHeaders?, withParameters: Parameters?, dataToSend: Any?, isImage: Bool?, isFile: Bool?, completion: @escaping callbackTypeAlias, progress: callbackTypeAliasFloat?) {
        let url = URL(string: urlStr)!
        
        if (withMethod == .get) {
            Alamofire.request(url, method: withMethod, parameters: withParameters, headers: withHeaders).responseString { (response) in
                if response.result.isSuccess {
                    let stringToReturn: String = response.result.value!
                    completion(stringToReturn)
                } else {
                    //                    can not get the result, and gets error
                    //                    delegate?.error(errorCode: result.errorCode, errorMessage: result.errorMessage, errorResult: result)
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
                    case .failure(let error):
                        completion(error)
                    }
                }
                
            }
            
        }
        
    }
    
    
    func sendMessageWithCallback(params: JSON, callback: CallbackProtocol?, sentCallback: CallbackProtocolWith3Calls?, deliverCallback: CallbackProtocolWith3Calls?, seenCallback: CallbackProtocolWith3Calls?, uniuqueIdCallback: callbackTypeAliasString?) {
        print("\n On Chat")
        print(":: params (to send): \n \(params)\n")
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
            //            returnData["threadId"] = JSON(theSubjectId)
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
        
        print("\n On Chat")
        print(":: MessageVO params (to send): \n \(messageVO) \n")
        
        if (sentCallback != nil) {
            Chat.mapOnSent[uniqueId] = sentCallback
            
            //            Chat.mapOnDeliver["\(threadId)"] =
            //            let threadArrCount = Chat.mapOnDeliver["\(threadId)"]?.count
            //            var nextNum = 1
            //            if let thc = Chat.mapOnDeliver["\(threadId)"]?.count {
            //                nextNum = thc + 1
            //            }
            //            let nextNumStr = "\(nextNum)"
            
            let uniqueIdDic: [String: CallbackProtocolWith3Calls] = [uniqueId: deliverCallback!]
            //            let objNumberDic: [String: [String: CallbackProtocolWith3Calls]] = [nextNumStr: uniqueIdDic]
            if Chat.mapOnDeliver["\(threadId)"] != nil {
                Chat.mapOnDeliver["\(threadId)"]!.append(uniqueIdDic)
            } else {
                Chat.mapOnDeliver["\(threadId)"] = [uniqueIdDic]
            }
            if Chat.mapOnSeen["\(threadId)"] != nil {
                Chat.mapOnSeen["\(threadId)"]!.append(uniqueIdDic)
            } else {
                Chat.mapOnSeen["\(threadId)"] = [uniqueIdDic]
            }
            
        } else {
            Chat.map[uniqueId] = callback
        }
        
        print("\n On Chat")
        print(":: map json: \n \(Chat.map) \n")
        print(":: map onSent json: \n \(Chat.mapOnSent) \n")
        print(":: map onDeliver json: \n \(Chat.mapOnDeliver) \n")
        print(":: map onSeen json: \n \(Chat.mapOnSeen) \n")
        
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
        print("\n On Chat")
        print(":: AsyncMessageContent of type JSON (to send to socket): \n \(str2) \n")
        
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
            print("\n On Chat")
            print(":: \t Try to send Ping \n")
            let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.PING.rawValue, "pushMsgType": 4]
            _ = sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: nil, deliverCallback: nil, seenCallback: nil, uniuqueIdCallback: nil)
        } else if (lastSentMessageTimeoutId != nil) {
            lastSentMessageTimeoutId?.suspend()
        }
    }
    
    
    
    func pushMessageHandler(params: JSON) {
        print("\n On Chat")
        print(":: receive message: \n \(params)\n")
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
        print("\n On Chat")
        print(":: content of received message: \n \(params)\n")
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
        case chatMessageVOTypes.CREATE_THREAD.rawValue:
            print("\n:: On Chat:\n Message CREATE_THREAD recieved\n")
            if Chat.map[uniqueId] != nil {
                let threadData = Conversation(messageContent: messageContent).formatToJSON()
                delegate?.threadEvents(type: "THREAD_NEW", result: threadData)
                
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.createThreadCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        case chatMessageVOTypes.MESSAGE.rawValue:
            chatMessageHandler(threadId: threadId, messageContent: messageContent)
            break
            
        case chatMessageVOTypes.SENT.rawValue:
            print("\n:: On Chat:\n Message SENT recieved\n")
            if Chat.mapOnSent[uniqueId] != nil {
                let callback: CallbackProtocolWith3Calls = Chat.mapOnSent[uniqueId]!
                messageContent = ["messageId": params["content"].stringValue]
                callback.onSent(uID: uniqueId, response: params) { (successJSON) in
                    self.sendCallbackToUserOnSent?(successJSON)
                }
                Chat.mapOnSent.removeValue(forKey: uniqueId)
            }
            break
            
        case chatMessageVOTypes.DELIVERY.rawValue:
            print("\n:: On Chat:\n Message DELIVERY recieved\n")
            
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
            
            var findItAt: Int?
            let threadIdObject = Chat.mapOnDeliver["\(threadId)"]
            if let threadIdObj = threadIdObject {
                let threadIdObjCount = threadIdObj.count
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
                    Chat.mapOnDeliver["\(threadId)"]?.remove(at: index)
                }
                
            }
            break
            
        case chatMessageVOTypes.SEEN.rawValue:
            print("\n:: On Chat:\n Message SEEN recieved\n")
            
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
            
            var findItAt: Int?
            let threadIdObject = Chat.mapOnSeen["\(threadId)"]
            if let threadIdObj = threadIdObject {
                let threadIdObjCount = threadIdObj.count
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
            
        case chatMessageVOTypes.PING.rawValue:
            break
            
        case chatMessageVOTypes.BLOCK.rawValue:
            
            break
            
        case chatMessageVOTypes.UNBLOCK.rawValue:
            
            break
            
        case chatMessageVOTypes.LEAVE_THREAD.rawValue:
            //
            break
        case chatMessageVOTypes.RENAME.rawValue:
            //
            break
        case chatMessageVOTypes.ADD_PARTICIPANT.rawValue:
            print("\n:: On Chat:\n Message ADD_PARTICIPANT recieved\n")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.addParticipantsCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            
            let threadIds = messageContent["id"].intValue
            let paramsToSend: JSON = ["threadIds": threadIds]
            getThreads(params: paramsToSend, uniqueId: { _ in }) { (response) in
                
                let responseModel: GetThreadsModel = response as! GetThreadsModel
                let responseJSON: JSON = responseModel.returnDataAsJSON()
                let threads = responseJSON["result"]["threads"].arrayValue
                self.delegate?.threadEvents(type: "THREAD_ADD_PARTICIPANTS", result: threads[0])
                self.delegate?.threadEvents(type: "THREAD_LAST_ACTIVITY_TIME", result: threads[0])
            }
            break
            
        case chatMessageVOTypes.GET_CONTACTS.rawValue:
            print("\n:: On Chat:\n Message GET_CONTACTS recieved\n")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.getContactsCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        case chatMessageVOTypes.GET_THREADS.rawValue:
            print("\n:: On Chat:\n Message GET_THREADS recieved\n")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.threadsCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        case chatMessageVOTypes.GET_HISTORY.rawValue:
            print("\n:: On Chat:\n Message GET_HISTORY recieved\n")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: nil)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.historyCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        case chatMessageVOTypes.REMOVED_FROM_THREAD.rawValue:
            let result: JSON = ["thread": threadId]
            delegate?.threadEvents(type: "THREAD_REMOVED_FROM", result: result)
            break
            
        case chatMessageVOTypes.REMOVE_PARTICIPANT.rawValue:
            print("\n:: On Chat:\n Message REMOVE_PARTICIPANT recieved\n")
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
            getThreads(params: paramsToSend, uniqueId: { (uniqueIdStr) in
                // print(uniqueIdStr)
            }) { (response) in
                let responseJSON = response as! JSON
                let threads = responseJSON["result"]["threads"].arrayValue
                self.delegate?.threadEvents(type: "THREAD_REMOVE_PARTICIPANTS", result: threads[0])
                self.delegate?.threadEvents(type: "THREAD_LAST_ACTIVITY_TIME", result: threads[0])
            }
            break
            
        case chatMessageVOTypes.MUTE_THREAD.rawValue:
            print("\n:: On Chat:\n Message MUTE_THREAD recieved\n")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: nil, resultAsString: messageContentAsString, contentCount: nil)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.muteThreadCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
                
                let paramsToSend: JSON = ["threadIds": [threadId]]
                getThreads(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
                    let myResponseModel: CreateThreadModel = myResponse as! CreateThreadModel
                    let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
                    let threads = myResponseJSON["result"]["threads"].arrayValue
                    self.delegate?.threadEvents(type: "THREAD_MUTE", result: threads.first!)
                }
            }
            break
            
        case chatMessageVOTypes.UNMUTE_THREAD.rawValue:
            print("\n:: On Chat:\n Message MUTE_THREAD recieved\n")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: nil, resultAsString: messageContentAsString, contentCount: nil)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.unmuteThreadCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
                
                let paramsToSend: JSON = ["threadIds": [threadId]]
                getThreads(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
                    let myResponseModel: CreateThreadModel = myResponse as! CreateThreadModel
                    let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
                    let threads = myResponseJSON["result"]["threads"].arrayValue
                    self.delegate?.threadEvents(type: "THREAD_UNMUTE", result: threads.first!)
                }
            }
            break
            
        case chatMessageVOTypes.UPDATE_THREAD_INFO.rawValue:
            print("\n:: On Chat:\n Message UPDATE_THREAD_INFO recieved\n")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: nil)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.updateThreadInfoCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
                
                let paramsToSend: JSON = ["threadIds": messageContent["id"].intValue]
                getThreads(params: paramsToSend, uniqueId: { _ in }) { (myResponse) in
                    let myResponseModel: CreateThreadModel = myResponse as! CreateThreadModel
                    let myResponseJSON: JSON = myResponseModel.returnDataAsJSON()
                    let threads = myResponseJSON["result"]["threads"].arrayValue
                    let thread: JSON = ["thread": threads.first!]
                    let result: JSON = ["result": thread]
                    self.delegate?.threadEvents(type: "THREAD_INFO_UPDATED", result: result)
                }
            }
            break
            
        case chatMessageVOTypes.FORWARD_MESSAGE.rawValue:
            chatMessageHandler(threadId: threadId, messageContent: messageContent)
            break
            
        case chatMessageVOTypes.USER_INFO.rawValue:
            print("\n:: On Chat:\n Message USER_INFO recieved\n")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: nil)
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
        case chatMessageVOTypes.GET_BLOCKED.rawValue:
            //
            break
        case chatMessageVOTypes.THREAD_PARTICIPANTS.rawValue:
            print("\n:: On Chat:\n Message THREAD_PARTICIPANTS recieved\n")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.threadParticipantsCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        case chatMessageVOTypes.EDIT_MESSAGE.rawValue:
            print("\n:: On Chat:\n Message EDIT_MESSAGE recieved\n")
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
            
        case chatMessageVOTypes.DELETE_MESSAGE.rawValue:
            print("\n:: On Chat:\n Message DELETE_MESSAGE recieved\n")
            if Chat.map[uniqueId] != nil {
                let returnData: JSON = createReturnData(hasError: false, errorMessage: "", errorCode: 0, result: messageContent, resultAsString: nil, contentCount: contentCount)
                let callback: CallbackProtocol = Chat.map[uniqueId]!
                callback.onResultCallback(uID: uniqueId, response: returnData, success: { (successJSON) in
                    self.deleteMessageCallbackToUser?(successJSON)
                }) { _ in }
                Chat.map.removeValue(forKey: uniqueId)
            }
            break
            
        case chatMessageVOTypes.THREAD_INFO_UPDATED.rawValue:
            //
            break
        case chatMessageVOTypes.LAST_SEEN_UPDATED.rawValue:
            //
            break
        case chatMessageVOTypes.SPAM_PV_THREAD.rawValue:
            //
            break
        case chatMessageVOTypes.ERROR.rawValue:
            //
            break
        default:
            //
            break
        }
    }
    
    
    
    
    func chatMessageHandler(threadId: Int, messageContent: JSON) {
        let message = Message(threadId: threadId, pushMessageVO: messageContent)
        if let messageParticipants = message.participant {
            delegate?.chatDeliver(messageId: message.id!, ownerId: messageParticipants.id!)
        }
        
        let myResult: JSON = ["message": message]
        delegate?.messageEvents(type: "MESSAGE_NEW", result: myResult)
        
        let myThreadId: JSON = ["threadIds": threadId]
        getThreads(params: myThreadId, uniqueId: { _ in }) { (threadsResult) in
            let threadsResultModel: GetThreadsModel = threadsResult as! GetThreadsModel
            let threadsResultJSON: JSON = threadsResultModel.returnDataAsJSON()
            
            let threads = threadsResultJSON["result"]["threads"].arrayValue
            
            if (messageContent["participant"]["id"].intValue != self.userInfo!["id"].intValue) {
                let result: JSON = ["thread": threads[0].intValue,
                                    "messageId": messageContent["id"].intValue,
                                    "senderId": messageContent["participant"]["id"].intValue]
                self.delegate?.threadEvents(type: "THREAD_UNREAD_COUNT_UPDATED", result: result)
            }
            
            let result: JSON = ["thread": threads[0].intValue]
            self.delegate?.threadEvents(type: "THREAD_LAST_ACTIVITY_TIME", result: result)
        }
    }
    
    
    func chatEditMessageHandler(threadId: Int, messageContent: JSON) {
        let message = Message(threadId: threadId, pushMessageVO: messageContent)
        let result: JSON = ["message": message]
        delegate?.messageEvents(type: "MESSAGE_EDIT", result: result)
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


// - MARK: Public Methods
extension Chat {
    
    public func getPeerId() -> Int {
        return peerId!
    }
    
    
    public func getCurrentUser() -> JSON {
        return userInfo!
    }
    
    
    
    
    
    
    public func getUserInfo(uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to get user info \n")
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.USER_INFO.rawValue]
        sendMessageWithCallback(params: sendMessageParams, callback: UserInfoCallback(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getUserInfoUniqueId) in
            uniqueId(getUserInfoUniqueId)
        }
        sendMessageWithCallback(params: sendMessageParams, callback: UserInfoCallback(), sentCallback: nil, deliverCallback: nil, seenCallback: nil, uniuqueIdCallback: nil)
        userInfoCallbackToUser = completion
    }
    
    
    public func getContacts(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to get Contacts with this parameters:")
        print("\(params ?? "??") \n")
        
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
            if let offset = parameters["name"].string {
                content.appendIfDictionary(key: "name", json: JSON(offset))
            }
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_CONTACTS.rawValue,
                                       "content": content]
        sendMessageWithCallback(params: sendMessageParams, callback: GetContactsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getContactUniqueId) in
            uniqueId(getContactUniqueId)
        }
        getContactsCallbackToUser = completion
    }
    
    
    public func getThreads(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to get threads with this parameters:")
        print("\(params ?? "params is empty") \n")
        
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
            if let name = parameters["name"].string {
                content.appendIfDictionary(key: "name", json: JSON(name))
            }
            if let new = parameters["new"].bool {
                content.appendIfDictionary(key: "new", json: JSON(new))
            }
            if let threadIds = parameters["threadIds"].arrayObject {
                content.appendIfDictionary(key: "threadIds", json: JSON(threadIds))
            }
        }
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_THREADS.rawValue,
                                       "content": content]
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetThreadsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getThreadUniqueId) in
            uniqueId(getThreadUniqueId)
        }
        threadsCallbackToUser = completion
    }
    
    
    public func getHistory(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to get history with this parameters:")
        print("\(params) \n")
        
        var content: JSON = ["count": 50, "offset": 0]
        if let count = params["count"].int {
            if count > 0 {
                content.appendIfDictionary(key: "count", json: JSON(count))
            }
        }
        if let offset = params["offset"].int {
            if offset > 0 {
                content.appendIfDictionary(key: "offset", json: JSON(offset))
            }
        }
        if let firstMessageId = params["firstMessageId"].int {
            if firstMessageId > 0 {
                content.appendIfDictionary(key: "firstMessageId", json: JSON(firstMessageId))
            }
        }
        if let lastMessageId = params["lastMessageId"].int {
            if lastMessageId > 0 {
                content.appendIfDictionary(key: "lastMessageId", json: JSON(lastMessageId))
            }
        }
        if let order = params["order"].string {
            content.appendIfDictionary(key: "order", json: JSON(order))
        }
        if let query = params["query"].string {
            content.appendIfDictionary(key: "query", json: JSON(query))
        }
        if let metadataCriteria = params["metadataCriteria"].string {
            content.appendIfDictionary(key: "metadataCriteria", json: JSON(metadataCriteria))
        } else if (params["metadataCriteria"] != JSON.null) {
            content["metadataCriteria"] = params["metadataCriteria"]
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.GET_HISTORY.rawValue,
                                       "content": content,
                                       "subjectId": params["threadId"].intValue]
        
        sendMessageWithCallback(params: sendMessageParams, callback: GetHistoryCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getHistoryUniqueId) in
            uniqueId(getHistoryUniqueId)
        }
        historyCallbackToUser = completion
    }
    
    
    public func getThreadParticipants(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to get thread participants with this parameters:")
        print("\(params ?? "params is empty") \n")
        
        var content: JSON = ["count": getHistoryCount, "offset": 0]
        var subjectId: Int = 0
        
        if let parameters = params {
            if let subId = parameters["threadId"].int {
                subjectId = subId
            }
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
            if let firstMessageId = parameters["firstMessageId"].int {
                if firstMessageId > 0 {
                    content.appendIfDictionary(key: "firstMessageId", json: JSON(firstMessageId))
                }
            }
            if let lastMessageId = parameters["lastMessageId"].int {
                if lastMessageId > 0 {
                    content.appendIfDictionary(key: "lastMessageId", json: JSON(lastMessageId))
                }
            }
            if let name = parameters["name"].string {
                content.appendIfDictionary(key: "name", json: JSON(name))
            }
        }
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.THREAD_PARTICIPANTS.rawValue,
                                       "content": content,
                                       "subjectId": subjectId]
        sendMessageWithCallback(params: sendMessageParams, callback: GetThreadParticipantsCallbacks(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (getParticipantsUniqueId) in
            uniqueId(getParticipantsUniqueId)
        }
        threadParticipantsCallbackToUser = completion
    }
    
    
    public func createThread(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to create thread with this parameters:")
        print("\(params ?? "params is empty") \n")
        /**
         * + CreateThreadRequest    {object}
         *    - ownerSsoId          {string}
         *    + invitees            {object}
         *       -id                {string}
         *       -idType            {int} ** inviteeVOidTypes
         *    - title               {string}
         *    - type                {int} ** createThreadTypes
         */
        var content: JSON = [:]
        if let parameters = params {
            if let title = parameters["title"].string {
                content.appendIfDictionary(key: "title", json: JSON(title))
            }
            if let type = parameters["type"].string {
                var theType: Int = 0
                switch type {
                case createThreadTypes.NORMAL.rawValue: theType = 0
                case createThreadTypes.OWNER_GROUP.rawValue: theType = 1
                case createThreadTypes.PUBLIC_GROUP.rawValue: theType = 2
                case createThreadTypes.CHANNEL_GROUP.rawValue: theType = 4
                case createThreadTypes.CHANNEL.rawValue: theType = 8
                default: print("not valid thread type on create thread")
                }
                content.appendIfDictionary(key: "type", json: JSON(theType))
            }
            if let title = parameters["title"].string {
                content.appendIfDictionary(key: "title", json: JSON(title))
            }
            
            if let invitees = parameters["invitees"].array {
                //                var tempInvitee = []
                //                for item in invitees {
                //                    tempInvitee.append(item)
                //                }
                content.appendIfDictionary(key: "invitees", json: JSON(invitees))
            }
        }
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.CREATE_THREAD.rawValue,
                                       "content": content]
        sendMessageWithCallback(params: sendMessageParams, callback: CreateThreadCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (createThreadUniqueId) in
            uniqueId(createThreadUniqueId)
        }
        createThreadCallbackToUser = completion
    }
    
    
    public func addParticipants(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to add participants with this parameters:")
        print("\(params ?? "params is empty") \n")
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
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: AddParticipantsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (addParticipantsUniqueId) in
            uniqueId(addParticipantsUniqueId)
        }
        addParticipantsCallbackToUser = completion
    }
    
    
    public func removeParticipants(params: JSON?, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to remove participants with this parameters:")
        print("\(params ?? "params is empty") \n")
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
            
            if let participants = parameters["participants"].arrayObject {
                sendMessageParams["content"] = JSON(participants)
            }
        }
        
        sendMessageWithCallback(params: sendMessageParams, callback: RemoveParticipantsCallback(parameters: sendMessageParams), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (removeParticipantsUniqueId) in
            uniqueId(removeParticipantsUniqueId)
        }
        removeParticipantsCallbackToUser = completion
    }
    
    
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
    
    
    public func sendTextMessage(params: JSON, uniqueId: @escaping (String) -> (), onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to send Message with this parameters:")
        print("\(params) \n")
        
        //        var metaData: JSON = [:]
        //        metaData = params["metaData"]
        //        let metaDataStr = "\(metaData)"
        
        let messageTxtContent = makeCustomTextToSend(textMessage: params["content"].stringValue)
        
        let content: JSON = ["content": messageTxtContent]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MESSAGE.rawValue, "pushMsgType": 4,
                                       "content": content]
        //        content.appendIfDictionary(key: "metaData", json: JSON(metaDataStr))
        
        if let threadId = params["subjectId"].int {
            sendMessageParams["subjectId"] = JSON(threadId)
            //            content.appendIfDictionary(key: "subjectId", json: JSON(threadId))
        }
        if let repliedTo = params["repliedTo"].int {
            sendMessageParams["repliedTo"] = JSON(repliedTo)
            //            content.appendIfDictionary(key: "repliedTo", json: JSON(repliedTo))
        }
        //        if let theContent = params["content"].string {
        //            content["≈"] = JSON(theContent)
        ////            content.appendIfDictionary(key: "content", json: JSON(theContent))
        //        }
        if let uniqueId = params["uniqueId"].string {
            sendMessageParams["uniqueId"] = JSON(uniqueId)
            //            content.appendIfDictionary(key: "uniqueId", json: JSON(uniqueId))
        }
        if let systemMetadata = params["systemMetadata"].arrayObject {
            sendMessageParams["systemMetadata"] = JSON(systemMetadata)
            //            content.appendIfDictionary(key: "systemMetadata", json: JSON(systemMetadata))
        }
        if let metaData = params["metaData"].arrayObject {
            let metaDataStr = "\(metaData)"
            sendMessageParams["metaData"] = JSON(metaDataStr)
            //            content.appendIfDictionary(key: "metaData", json: JSON(metaDataStr))
        }
        
        
        sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(), deliverCallback: SendMessageCallbacks(), seenCallback: SendMessageCallbacks()) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
    }
    
    
    public func editMessage(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to edit message with this parameters:")
        print("\(params)\n")
        
        let messageTxtContent = makeCustomTextToSend(textMessage: params["content"].stringValue)
        
        let content: JSON = ["content": messageTxtContent]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.EDIT_MESSAGE.rawValue,
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
    
    
    public func deleteMessage(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to edit message with this parameters:")
        print("\(params)\n")
        
        let deleteForAllVar = params["deleteForAll"]
        let content: JSON = ["deleteForAll": "\(deleteForAllVar)"]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELETE_MESSAGE.rawValue,
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
    
    
    public func replyMessageWith3Callbacks(params: JSON, uniqueId: @escaping (String) -> (), onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to reply Message with this parameters:")
        print("\(params) \n")
        
        let messageTxtContent = makeCustomTextToSend(textMessage: params["content"].stringValue)
        
        let content: JSON = ["content": messageTxtContent]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MESSAGE.rawValue,
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
        
        
        sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(), deliverCallback: SendMessageCallbacks(), seenCallback: SendMessageCallbacks()) { (theUniqueId) in
            uniqueId(theUniqueId)
        }
        
        sendCallbackToUserOnSent = onSent
        sendCallbackToUserOnDeliver = onDelivere
        sendCallbackToUserOnSeen = onSeen
    }
    
    
    public func forwardMessageWith3Callbacks(params: JSON, uniqueIds: @escaping (String) -> (), onSent: @escaping callbackTypeAlias, onDelivere: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        /*
         subjectId(destination):    Int
         content:                   "[Arr]"
         */
        
        //        let threadId = params["subjectId"].intValue
        let messageIdsList: [Int] = params["content"].arrayObject! as! [Int]
        var uniqueIdsList: [String] = []
        //            let content: JSON = ["content": "\(messageIdsList)"]
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.FORWARD_MESSAGE.rawValue,
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
            
            sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: SendMessageCallbacks(), deliverCallback: SendMessageCallbacks(), seenCallback: SendMessageCallbacks()) { (theUniqueId) in
                uniqueIds(theUniqueId)
            }
            
            sendCallbackToUserOnSent = onSent
            sendCallbackToUserOnDeliver = onDelivere
            sendCallbackToUserOnSeen = onSeen
            
        }
        
        
        
        
        
        
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
    
    
    public func addContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        
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
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil)
        
    }
    
    
    public func updateContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        
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
        
        if let cellphoneNumber = params["lastName"].string {
            data["cellphoneNumber"] = JSON(cellphoneNumber)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "cellphoneNumber is required for Updating Contact!", errorResult: nil)
        }
        
        if let email = params["lastName"].string {
            data["email"] = JSON(email)
        } else {
            delegate?.chatError(errorCode: 999, errorMessage: "email is required for Updating Contact!", errorResult: nil)
        }
        
        let uniqueId: String = generateUUID()
        data["uniqueId"] = JSON(uniqueId)
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.UPDATE_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil)
        
    }
    
    
    public func removeContact(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        
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
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = RemoveContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil)
        
    }
    
    
    public func syncContacts(uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        
        let myUniqueId = generateUUID()
        uniqueId(myUniqueId)
        
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
                        
                        let contactsJSON: JSON = ["firstName": firstName,
                                                  "lastName": lastName,
                                                  "cellphoneNumber": phoneNumber ?? "",
                                                  "email": emailAddress ?? ""]
                        self.addContact(params: contactsJSON, uniqueId: { _ in }, completion: { (myResponse) in
                            completion(myResponse)
                        })
                    })
                } catch {
                    
                }
                
            }
        }
    }
    
    
    public func uploadFile(params: JSON, dataToSend: Data, uniqueId: @escaping (String) -> (), progress: @escaping (Float) -> (), completion: @escaping callbackTypeAlias) {
        
        var fileName:           String  = ""
        //        var fileType:           String  = ""
        var fileSize:           Int     = 0
        var fileExtension:      String  = ""
        
        var uploadThreadId:     Int     = 0
        var uploadUniqueId:     String  = ""
        var originalFileName:   String  = ""
        
        var uploadFileData: JSON = []
        
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
        //        uploadFileData["fileSize"] = JSON(fileSize)
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
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: parameters, dataToSend: dataToSend, isImage: false, isFile: true, completion: { (response) in
            
            let myResponse: JSON = response as! JSON
            
            let hasError        = myResponse["hasError"].boolValue
            let errorMessage    = myResponse["errorMessage"].stringValue
            let errorCode       = myResponse["errorCode"].intValue
            
            if (!hasError) {
                let resultData = myResponse["result"]
                let uploadFileModel = UploadFileModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                completion(uploadFileModel)
            }
        }) { (myProgress) in
            progress(myProgress)
        }
        
    }
    
    
    public func uploadImage(params: JSON, dataToSend: Data, uniqueId: @escaping (String) -> (), progress: @escaping (Float) -> (), completion: @escaping callbackTypeAlias) {
        
        var fileName:           String  = ""
        var fileType:           String  = ""
        var fileSize:           Int     = 0
        var fileExtension:      String  = ""
        
        var uploadFileData: JSON = []
        
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
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: parameters, dataToSend: dataToSend, isImage: true, isFile: false, completion: { (response) in
            
            let myResponse: JSON = response as! JSON
            let hasError        = myResponse["hasError"].boolValue
            let errorMessage    = myResponse["errorMessage"].stringValue
            let errorCode       = myResponse["errorCode"].intValue
            
            if (!hasError) {
                let resultData = myResponse["result"]
                let uploadImageModel = UploadImageModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                completion(uploadImageModel)
            }
        }) { (myProgress) in
            progress(myProgress)
        }
        
    }
    
    
    public func sendFileMessage(textMessagParams: JSON, fileParams: JSON, imageToSend: Data?, fileToSend: Data?, uniqueId: @escaping (String) -> (), uploadProgress: @escaping (Float) -> (), onSent: @escaping callbackTypeAlias, onDelivered: @escaping callbackTypeAlias, onSeen: @escaping callbackTypeAlias) {
        
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
        
        var metaData: JSON = []
        
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
        
        var paramsToSendToSendMessage: JSON = ["uniqueId": messageUniqueId]
        
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
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_IMAGE.rawValue)?imageId=\(myResponse.uploadImage.id ?? 0)&hashCode=\(myResponse.uploadImage.hashCode ?? "")"
                metaData["file"]["link"]            = JSON(link)
                metaData["file"]["id"]              = JSON(myResponse.uploadImage.id ?? 0)
                metaData["file"]["name"]            = JSON(myResponse.uploadImage.name ?? "")
                metaData["file"]["height"]          = JSON(myResponse.uploadImage.height ?? 0)
                metaData["file"]["width"]           = JSON(myResponse.uploadImage.width ?? 0)
                metaData["file"]["actualHeight"]    = JSON(myResponse.uploadImage.actualHeight ?? 0)
                metaData["file"]["actualWidth"]     = JSON(myResponse.uploadImage.actualWidth ?? 0)
                metaData["file"]["hashCode"]        = JSON(myResponse.uploadImage.hashCode ?? "")
                
                paramsToSendToSendMessage["metaData"] = JSON("\(metaData)")
                
                sendMessageWith(paramsToSendToSendMessage: paramsToSendToSendMessage)
            }
        } else if let file = fileToSend {
            uploadFile(params: paramsToSendToUpload, dataToSend: file, uniqueId: { _ in }, progress: { (progress) in
                uploadProgress(progress)
            }) { (response) in
                
                let myResponse: UploadFileModel = response as! UploadFileModel
                let link = "\(self.SERVICE_ADDRESSES.FILESERVER_ADDRESS)\(SERVICES_PATH.GET_FILE.rawValue)?fileId=\(myResponse.uploadFile.id ?? 0)&hashCode=\(myResponse.uploadFile.hashCode ?? "")"
                metaData["file"]["link"]            = JSON(link)
                metaData["file"]["id"]              = JSON(myResponse.uploadFile.id ?? 0)
                metaData["file"]["name"]            = JSON(myResponse.uploadFile.name ?? "")
                metaData["file"]["hashCode"]        = JSON(myResponse.uploadFile.hashCode ?? "")
                
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
    
    
    public func muteThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to mute threads with this parameters:")
        print("\(params) \n")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.MUTE_THREAD.rawValue,
                                       "subjectId": params["subjectId"].intValue]
        
        sendMessageWithCallback(params: sendMessageParams, callback: MuteThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        muteThreadCallbackToUser = completion
    }
    
    
    public func unmuteThread(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to mute threads with this parameters:")
        print("\(params) \n")
        
        let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UNMUTE_THREAD.rawValue,
                                       "subjectId": params["subjectId"].intValue]
        
        sendMessageWithCallback(params: sendMessageParams, callback: UnmuteThreadCallbacks(), sentCallback: nil, deliverCallback: nil, seenCallback: nil) { (muteThreadUniqueId) in
            uniqueId(muteThreadUniqueId)
        }
        unmuteThreadCallbackToUser = completion
    }
    
    
    public func searchContacts(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        
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
        
        if let q = params["q"].string {
            data["q"] = JSON(q)
        }
        
        if let uniqueId = params["uniqueId"].string {
            data["uniqueId"] = JSON(uniqueId)
        }
        
        if let id = params["id"].int {
            data["id"] = JSON(id)
        }
        
        if let typeCode = params["typeCode"].int {
            data["typeCode"] = JSON(typeCode)
        }
        
        if let size = params["size"].int {
            data["size"] = JSON(size)
        } else { data["size"] = JSON(50) }
        
        if let offset = params["offset"].int {
            data["offset"] = JSON(offset)
        } else { data["offset"] = JSON(0) }
        
        
        let url = "\(SERVICE_ADDRESSES.PLATFORM_ADDRESS)\(SERVICES_PATH.SEARCH_CONTACTS.rawValue)"
        let method: HTTPMethod = HTTPMethod.post
        let headers: HTTPHeaders = ["_token_": token, "_token_issuer_": "1"]
        
        httpRequest(from: url, withMethod: method, withHeaders: headers, withParameters: data, dataToSend: nil, isImage: nil, isFile: nil, completion: { (response) in
            let jsonRes: JSON = response as! JSON
            let contactsResult = ContactModel(messageContent: jsonRes)
            completion(contactsResult)
        }, progress: nil)
        
    }
    
    
    public func updateThreadInfo(params: JSON, uniqueId: @escaping (String) -> (), completion: @escaping callbackTypeAlias) {
        print("\n On Chat")
        print(":: \t Try to request to update thread info with this parameters:")
        print("\(params) \n")
        
        var sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.UPDATE_THREAD_INFO.rawValue]
        
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
    
    
    
    public func deliver(params: JSON) {
        if let theUserInfo = userInfo {
            if (params["ownerId"].intValue != theUserInfo["id"].intValue) {
                let sendMessageParams: JSON = ["chatMessageVOType": chatMessageVOTypes.DELIVERY.rawValue,
                                               "content": params["messageId"].intValue,
                                               "pushMsgType": 3]
                sendMessageWithCallback(params: sendMessageParams, callback: nil, sentCallback: nil, deliverCallback: nil, seenCallback: nil, uniuqueIdCallback: nil)
            }
        }
    }
    
    
    public func generateUUID() -> String {
        let myUUID = NSUUID().uuidString
        return myUUID
    }
    
    
    public func logOut() {
        asyncClient?.asyncLogOut()
    }
    
    
    public func getChatState() -> JSON {
        return chatFullStateObject
    }
    
    
    public func reconnect() {
        asyncClient?.asyncReconnectSocket()
    }
    
    
    public func setTocken(newToken: String) {
        token = newToken
    }
    
    
}




//






// Calbacks Classes
extension Chat {
    
    
    private class UserInfoCallback: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            print("\n On Chat")
            print(":: \t UserInfoCallback \n")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let resultData = response["result"]
                
                let userInfoModel = UserInfoModel(messageContent: resultData, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(userInfoModel)
            } else {
                failure(["result": false])
            }
        }
    }
    
    
    private class GetContactsCallback: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            print("\n On Chat")
            print(":: \t GetContacts \n")
            
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
                
                let getContactsModel = GetContactsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getContactsModel)
            }
        }
    }
    
    
    private class GetThreadsCallbacks: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            print("\n On Chat")
            print(":: \t ThreadCallback \n")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let content = sendParams["content"]
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                let getThreadsModel = GetThreadsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getThreadsModel)
                
            }
        }
        
    }
    
    
    private class GetHistoryCallbacks: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            print("\n On Chat")
            print(":: \t HistoryCallback \n")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let content = sendParams["content"]
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                let getHistoryModel = GetHistoryModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getHistoryModel )
            }
        }
    }
    
    
    private class GetThreadParticipantsCallbacks: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            print("\n On Chat")
            print(":: \t ThreadParticipantsCallback \n")
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
                let content = sendParams["content"]
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                let getThreadParticipantsModel = GetThreadParticipantsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getThreadParticipantsModel)
            }
        }
    }
    
    
    private class CreateThreadCallback: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            print("\n On Chat")
            print(":: \t CreateThreads \n")
            
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
    
    
    private class UpdateThreadInfoCallback: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            print("\n On Chat")
            print(":: \t UpdateThreadInfoCallback \n")
            print("++++++++++++++++++++++++++++")
            print("++++++++++++++++++++++++++++")
            print("\(response)")
            print("++++++++++++++++++++++++++++")
            print("++++++++++++++++++++++++++++")
            success(response)
        }
        
        
    }
    
    
    private class AddParticipantsCallback: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            print("\n On Chat")
            print(":: \t AddParticipantsCallback \n")
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
                
                let addParticipantModel = AddParticipantModel(messageContent: messageContent, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(addParticipantModel)
            }
        }
    }
    
    
    private class RemoveParticipantsCallback: CallbackProtocol {
        var sendParams: JSON
        init(parameters: JSON) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            print("\n On Chat")
            print(":: \t RemoveParticipantsCallback \n")
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
                let messageContent = response["result"]
                
                let addParticipantModel = AddParticipantModel(messageContent: messageContent, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(addParticipantModel)
            }
        }
    }
    
    
    private class SendMessageCallbacks: CallbackProtocolWith3Calls {
        func onSent(uID: String, response: JSON, success: @escaping callbackTypeAlias) {
            //
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
            print("\n On Chat")
            print(":: \t EditMessage \n")
            
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
            print("\n On Chat")
            print(":: \t EditMessage \n")
            
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
                success(returnData)
            }
        }
        
    }
    
    
    private class MuteThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            print("\n On Chat")
            print(":: \t MuteThreadCallback \n")
            
            success(response)
        }
        
    }
    
    
    private class UnmuteThreadCallbacks: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            print("\n On Chat")
            print(":: \t UnmuteThreadCallback \n")
            
            success(response)
        }
        
    }
    
    
}


















































