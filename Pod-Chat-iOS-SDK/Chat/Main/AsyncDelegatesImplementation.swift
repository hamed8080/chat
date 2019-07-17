//
//  AsyncDelegatesImplementation.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import FanapPodAsyncSDK


extension Chat: AsyncDelegates {
    
    /*
     * Async "asyncConnect" delegate
     *
     * when Asyn is connected, this delegate method will fire
     * it also sends, newPeerId of the user
     *
     */
    public func asyncConnect(newPeerID: Int) {
        /*
         *  -> get the "newPeerId" from this method and put it on the "peerId" property
         *  -> fire "chatConnect" delegate
         *
         */
        log.verbose("Async Connected", context: "Chat: DelegateComesFromAsync")
        peerId = newPeerID
        delegate?.chatConnect()
    }
    
    /*
     * Async "asyncDisconnect" delegate
     *
     * when Asyn is disconnected, this delegate method will fire
     *
     */
    public func asyncDisconnect() {
        /*
         *  -> put the "peerId" to the "oldPeerId"
         *  -> empty value of the "peerId"
         *  -> fire "chatDisconnect" delegate
         *
         */
        log.verbose("Async Disconnected", context: "Chat: DelegateComesFromAsync")
        oldPeerId = peerId
        peerId = nil
        delegate?.chatDisconnect()
    }
    
    /*
     * Async "asyncReconnect" delegate
     *
     * when Async is reconnected, this delegate method will fire
     *
     */
    public func asyncReconnect(newPeerID: Int) {
        /*
         *  -> get the "newPeerId" from this method and put it on the "peerId" property
         *  -> fire "chatReconnect" delegate
         *
         */
        log.verbose("Async Reconnected", context: "Chat: DelegateComesFromAsync")
        peerId = newPeerID
        delegate?.chatReconnect()
    }
    
    /*
     * Async "asyncStateChanged" delegate
     *
     * when Async state changes, it fire this delegate method, and sends some information with itself
     *
     */
    public func asyncStateChanged(socketState: Int, timeUntilReconnect: Int, deviceRegister: Bool, serverRegister: Bool, peerId: Int) {
        let logMsg: String = "Chat state changed: \n|| socketState = \(socketState) \n|| timeUntilReconnect = \(timeUntilReconnect) \n|| deviceRegister = \(deviceRegister) \n|| serverRegister = \(serverRegister)"
        /*
         *  -> get this variables and save them all inside the "chatFullStateObject" property
         *  -> if the "socketState" is equal to "1" (CONNECTED):
         *      -> change value of the "chatState" to "true" (means that Async is connected)
         *      -> then send a "ping" message
         *  -> if the "socketState" is equal to "3" (CLOSED):
         *      -> change value of the "chatState" to "false" (means that Async is not connected)
         *  -> at the end, fire the "chatState" delegate with the "chatFullStateObject" property thar we filled it earlier
         *
         */
        
        log.verbose(logMsg, context: "Chat: DelegateComesFromAsync")
        chatFullStateObject = ["socketState": socketState,
                               "timeUntilReconnect": timeUntilReconnect,
                               "deviceRegister": deviceRegister,
                               "serverRegister": serverRegister,
                               "peerId": peerId]
        switch (socketState) {
        case 0: // CONNECTING
            break
        case 1: // CONNECTED
            chatState = true
            ping()
            break
        case 2: // CLOSING
            break
        case 3: // CLOSED
            chatState = false
            break
        default:
            break
        }
        delegate?.chatState(state: socketState)
    }
    
    /*
     * Async "asyncError" delegate
     *
     * Errors form Asyn are comming from this delegate method,
     * it has some information about the error with it
     *
     */
    public func asyncError(errorCode: Int, errorMessage: String, errorEvent: Any?) {
        /*
         *  -> fire "chatError" delegate, and sends the informations that comes on this method with it
         *
         */
        log.verbose("Error comes from Async", context: "Chat: DelegateComesFromAsync")
        delegate?.chatError(errorCode: errorCode, errorMessage: errorMessage, errorResult: errorEvent)
    }
    
    /*
     * Async "asyncReady" delegate
     *
     * when Async id ready, this method will fire
     * it means, that the async is connected, it has peerId, device registerd, server registerd so Async is ready
     *
     */
    public func asyncReady() {
        /*
         * -> call "handleAsyncReady" method, which will fire "chatReady" or "chatError" delegate
         *
         */
        log.verbose("Async Ready", context: "Chat: DelegateComesFromAsync")
        handleAsyncReady()
    }
    
    
    // TODO: this delegate method should be delete, because it is not necessary
    public func asyncSendMessage(params: Any) {
        // this message is sends through Async
        print("\n\n\n\n^^^^^^^^^^^^^^^^^\n^^^^^^^^^^^^^^^^^\nThis Message sends through Async: \n \(params)\n^^^^^^^^^^^^^^^^")
    }
    
    /*
     * Async "asyncReceiveMessage" delegate
     *
     * when a message comes from server, Async will send it to us throuth this delegate method
     *
     */
    // TODO: try to get this message as a Model
    public func asyncReceiveMessage(params: JSON) {
        /*
         *  -> get the message from Async delegate
         *  -> convert the JSON to "AsyncMessage" Model and send it to the "handleReceiveMessageFromAsync" method
         *
         */
        log.debug("content of received message: \n \(params)", context: "Chat")
        
        let asyncMessage = AsyncMessage(withContent: params)
        handleReceiveMessageFromAsync(withContent: asyncMessage)
    }
    
    
    
    
    /*
     * Handle AsyncReady:
     *
     * when Async Ready notification comes from Asyn, this function will triger
     * it will fire ChatReady or Error to the client
     *
     *  - Access:   Private
     *  - Inputs:   _
     *  - Outputs:  _
     *
     */
    // TODO: ther is no timer send the getUserInfo request again.
    func handleAsyncReady() {
        log.verbose("HandleAsyncReady", context: "Chat")
        /*
         *  -> get the peerId from Async
         *  -> if Chat has "userInfo", we will fire the chatReady with its content
         *  -> otherwise we will do this:
         *      -> for every 10seconds (at most 5 time), try to getUserInfo until the server will respond to this request
         *      -> if we got the server response, we will fire the chatReady
         *      -> otherwise we will fire an error to the client
         *
         */
        
        peerId = asyncClient?.asyncGetPeerId()
        
        // TODO: i have to implement a timer to check this part for every 10second (5 times at most!)
        if userInfo == nil {
            if (getUserInfoRetryCount < getUserInfoRetry) {
                getUserInfoRetryCount += 1
                
                getUserInfo(uniqueId: { _ in }, completion: { (result) in
                    let resultModel: UserInfoModel = result as! UserInfoModel
                    log.verbose("get info result comes, and save userInfo: \n \(resultModel.returnDataAsJSON())", context: "Chat")
                    
                    if resultModel.hasError == false {
                        self.userInfo = User(withUserObject: resultModel.user)
                        self.chatState = true
                        self.delegate?.chatReady(withUserInfo: self.userInfo!)
                        if self.enableCache {
                            self.getAllThreads(withInputModel: GetAllThreadsRequestModel(summary: true, typeCode: nil))
                        }
                    }
                }) { _ in }
                
            }
        } else {
            getUserInfoRetryCount = 0
            chatState = true
            delegate?.chatReady(withUserInfo: userInfo!)
        }
    }
    
    
    /*
     * Handle ReceiveMessage From Async:
     *
     *
     *
     */
    // TODO: duble check this funciton, where i setup a timer to check connetion
    // why did i try to reconnect to socket from here???? itn't it of the Async responsibility??
    func handleReceiveMessageFromAsync(withContent: AsyncMessage) {
        /*
         *  -> stop the "lastReceivedMessageTimeoutId" timer (that contains the timer to send ping to chat server)
         *  -> on the global thread
         *      -> set the current time to "lastReceivedMessageTime" (it means, time of the last message that comes from Async is right now)
         *      -> set timer to ??
         *
         *
         *  -> get AsyncMessage content
         *  -> convert it to "ChatMessage" model
         *  -> send it to "receivedMessageHandler" method
         *
         */
        
        
        // checkout to keep the Chat alive
        self.lastReceivedMessageTimeoutId?.suspend()
        DispatchQueue.global().async {
            self.lastReceivedMessageTime = Date()
            let myTimeInterval = Double(self.chatPingMessageInterval) * 1.5
            self.lastReceivedMessageTimeoutId = RepeatingTimer(timeInterval: myTimeInterval)
            self.lastReceivedMessageTimeoutId?.eventHandler = {
                if let lastReceivedMessageTimeBanged = self.lastReceivedMessageTime {
                    let elapsed = Int(Date().timeIntervalSince(lastReceivedMessageTimeBanged))
                    if (elapsed >= self.connectionCheckTimeout) {
                        DispatchQueue.main.async {
                            self.asyncClient?.asyncReconnectSocket()
                        }
                        self.lastReceivedMessageTimeoutId?.suspend()
                    }
                }
            }
            self.lastReceivedMessageTimeoutId?.resume()
        }
        
        let chatMessage = ChatMessage(withContent: withContent.content.convertToJSON())
        receivedMessageHandler(withContent: chatMessage)
    }
    
    
}


class AsyncMessage {
    
    let content:    String  // String of JSON
    let id:         Int
    let senderId:   Int
    let senderName: String?
    let type:       Int
    
    init(content: String, id: Int, senderId: Int, senderName: String?, type: Int) {
        self.content    = content
        self.id         = id
        self.senderId   = senderId
        self.senderName = senderName
        self.type       = type
    }
    
    init(withContent: JSON) {
        self.content    = withContent["content"].stringValue
        self.id         = withContent["id"].intValue
        self.senderId   = withContent["senderId"].intValue
        self.senderName = withContent["senderName"].string
        self.type       = withContent["type"].intValue
    }
    
}


class ChatMessage {

    let code:           Int?
    let content:        String? // String of JSON
    let contentCount:   Int?
    let message:        String?
    let messageType:    Int
    let subjectId:      Int?
    let time:           Int
    let type:           Int
    let uniqueId:       String
    
    init(code: Int? ,content: String?, contentCount: Int?, message: String?, messageType: Int, subjectId: Int?, time: Int, type: Int, uniqueId: String) {
        self.code           = code
        self.content        = content
        self.contentCount   = contentCount
        self.message        = message
        self.messageType    = messageType
        self.subjectId      = subjectId
        self.time           = time
        self.type           = type
        self.uniqueId       = uniqueId
    }
    
    init(withContent: JSON) {
        self.code           = withContent["code"].int
        self.content        = withContent["content"].string
        self.contentCount   = withContent["contentCount"].int
        self.message        = withContent["message"].string
        self.messageType    = withContent["messageType"].intValue
        self.subjectId      = withContent["subjectId"].int
        self.time           = withContent["time"].intValue
        self.type           = withContent["type"].intValue
        self.uniqueId       = withContent["uniqueId"].stringValue
    }
    
    func returnToJSON() -> JSON {
        let myReturnValue: JSON = ["code":          code ?? NSNull(),
                                   "content":       content ?? NSNull(),
                                   "contentCount":  contentCount ?? NSNull(),
                                   "message":       message ?? NSNull(),
                                   "messageType":   messageType,
                                   "subjectId":     subjectId ?? NSNull(),
                                   "time":          time,
                                   "type":          type,
                                   "uniqueId":      uniqueId]
        return myReturnValue
    }
    
}



class SendChatMessageVO {
    
    let chatMessageVOType:  Int
    var content:            String? = nil
    var metaData:           String? = nil
    var repliedTo:          Int?    = nil
    var systemMetadata:     String? = nil
    var subjectId:          Int?    = nil
    let token:              String
    var tokenIssuer:        Int?    = nil
    var typeCode:           String? = nil
    var uniqueId:           String? = nil
    
    var isCreateThreadAndSendMessage: Bool
    
    init(chatMessageVOType: Int,
         content:           String?,
         metaData:          String?,
         repliedTo:         Int?,
         systemMetadata:    String?,
         subjectId:         Int?,
         token:             String,
         tokenIssuer:       Int?,
         typeCode:          String?,
         uniqueId:          String?,
         isCreateThreadAndSendMessage: Bool?) {
        
        self.content            = content
        self.metaData           = metaData
        self.repliedTo          = repliedTo
        self.systemMetadata     = systemMetadata
        self.subjectId          = subjectId
        self.token              = token
        self.tokenIssuer        = tokenIssuer
        self.chatMessageVOType  = chatMessageVOType
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId
        
        self.isCreateThreadAndSendMessage   = isCreateThreadAndSendMessage ?? false
        
        func generateUUID() -> String {
            return ""
        }
        
        self.uniqueId = ""
        if let uID = uniqueId {
            self.uniqueId = uID
        } else if (chatMessageVOType == chatMessageVOTypes.DELETE_MESSAGE.rawValue) {
            if let contentJSON = content?.convertToJSON() {
                if let x = contentJSON["ids"].arrayObject {
                    if (x.count <= 1) {
                        self.uniqueId = generateUUID()
                    }
                } else {
                    self.uniqueId = generateUUID()
                }
            }
        } else if (chatMessageVOType == chatMessageVOTypes.PING.rawValue) {
            self.uniqueId = generateUUID()
        }
        
    }
    
    init(content: JSON) {
        
        self.token              = content["token"].stringValue
        self.tokenIssuer        = content["tokenIssuer"].int ?? 1
        self.chatMessageVOType  = content["chatMessageVOType"].intValue
        
        if let myContent = content["content"].string {
            self.content = myContent
        }
        if let myMetaData = content["metaData"].string {
            self.metaData = myMetaData
        }
        if let myRepliedTo = content["repliedTo"].int {
            self.repliedTo = myRepliedTo
        }
        if let mySystemMetadata = content["systemMetadata"].string {
            self.systemMetadata = mySystemMetadata
        }
        if let mySubjectId = content["subjectId"].int {
            self.subjectId = mySubjectId
        }
        
        if let myTypeCode = content["typeCode"].string {
            self.typeCode = myTypeCode
        }
        
        self.isCreateThreadAndSendMessage   = content["isCreateThreadAndSendMessage"].bool ?? false
        
        func generateUUID() -> String {
            return ""
        }
        
        self.uniqueId = ""
        if let uID = content["uniqueId"].string {
            self.uniqueId = uID
        } else if (content["chatMessageVOType"].intValue == chatMessageVOTypes.DELETE_MESSAGE.rawValue) {
            if let x = content["content"]["ids"].arrayObject {
                if x.count <= 1 {
                    self.uniqueId = generateUUID()
                }
            } else {
                self.uniqueId = generateUUID()
            }
        } else if (content["chatMessageVOType"].intValue != chatMessageVOTypes.PING.rawValue) {
            self.uniqueId = generateUUID()
        }
        
    }
    
    
    func convertModelToJSON() -> JSON {
        var messageVO: JSON = ["token":         token,
                               "tokenIssuer":   tokenIssuer ?? 1,
                               "type":          chatMessageVOType]
        if let theMessage = content {
            messageVO["content"] = JSON(theMessage)
        }
        if let theMetaData = metaData {
            messageVO["metaData"] = JSON(theMetaData)
        }
        if let theRepliedTo = repliedTo {
            messageVO["repliedTo"] = JSON(theRepliedTo)
        }
        if let theSubjectId = subjectId {
            messageVO["subjectId"] = JSON(theSubjectId)
        }
        if let theSystemMetadata = systemMetadata {
            messageVO["systemMetadata"] = JSON(theSystemMetadata)
        }
        if let theTypeCode = typeCode {
            messageVO["typeCode"] = JSON(theTypeCode)
        }
        if let theUniqueId = uniqueId {
            messageVO["uniqueId"] = JSON(theUniqueId)
        }
        
        return messageVO
    }
    
    func convertModelToString() -> String {
        return "\(convertModelToJSON())"
    }
    
}



class SendAsyncMessageVO {
    
    var content:        String
    let msgTTL:         Int
    let peerName:       String
    let priority:       Int
    let pushMsgType:    Int?
    
    init(content: String, msgTTL: Int, peerName: String, priority: Int, pushMsgType: Int?) {
        self.content        = content
        self.msgTTL         = msgTTL
        self.peerName       = peerName
        self.priority       = priority
        self.pushMsgType    = pushMsgType
    }
    
    init(content: JSON) {
        self.content        = content["content"].stringValue
        self.msgTTL         = content["ttl"].intValue
        self.peerName       = content["peerName"].stringValue
        self.priority       = content["priority"].int ?? 1
        self.pushMsgType    = content["pushMsgType"].intValue
    }
    
    func convertModelToJSON() -> JSON {
        let messageVO: JSON = ["content":   content,
                               "peerName":  peerName,
                               "priority":  priority,
                               "ttl":       msgTTL]
        
        return messageVO
    }
    
    func convertModelToString() -> String {
        let model = convertModelToJSON()
        let stringModel = "\(model)"
        let str = String(stringModel.filter { !" \n\t\r".contains($0) })
        return str
    }
    
    
}




