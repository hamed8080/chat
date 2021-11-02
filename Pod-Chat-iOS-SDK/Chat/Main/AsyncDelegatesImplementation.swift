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
        log.info("Async Connected", context: "Chat: DelegateComesFromAsync")
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
        log.info("Async Disconnected", context: "Chat: DelegateComesFromAsync")
        oldPeerId = peerId
        peerId = nil
        isChatReady = false
        delegate?.chatDisconnect()
        
        stopAllChatTimers()
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
        log.info("Async Reconnected", context: "Chat: DelegateComesFromAsync")
        peerId = newPeerID
        delegate?.chatReconnect()
    }
    
    /*
     * Async "asyncStateChanged" delegate
     *
     * when Async state changes, it fire this delegate method, and sends some information with itself
     *
     */
    public func asyncStateChanged(socketState: SocketStateType, timeUntilReconnect: Int, deviceRegister: Bool, serverRegister: Bool, peerId: Int) {
        let logMsg: String = "Chat state changed: \n|| socketState = \(socketState) \n|| timeUntilReconnect = \(timeUntilReconnect) \n|| deviceRegister = \(deviceRegister) \n|| serverRegister = \(serverRegister)"
        log.info(logMsg, context: "Chat: DelegateComesFromAsync")
        /*
         *  -> get this variables and save them all inside the "chatFullStateObject" property
         *  -> if the "socketState" is equal to "1" (CONNECTED):
         *      -> change value of the "isChatReady" to "true" (means that Async is connected)
         *      -> then send a "ping" message
         *  -> if the "socketState" is equal to "3" (CLOSED):
         *      -> change value of the "isChatReady" to "false" (means that Async is not connected)
         *  -> at the end, fire the "isChatReady" delegate with the "chatFullStateObject" property thar we filled it earlier
         *
         */
        
        var state: AsyncStateType!
        switch (socketState) {
        case .CONNECTING:
            state = AsyncStateType.CONNECTING
            isChatReady = false
            break
        case .CONNECTED:
            state = AsyncStateType.CONNECTED
            ping()
            break
        case .CLOSING:
            state = AsyncStateType.CLOSING
            isChatReady = false
            break
        case .CLOSED:
            state = AsyncStateType.CLOSED
            isChatReady = false
            break
        }
        chatFullStateObject = ChatFullStateModel(socketState:       state,
                                                 timeUntilReconnect: timeUntilReconnect,
                                                 deviceRegister:    deviceRegister,
                                                 serverRegister:    serverRegister,
                                                 peerId:            peerId)
        delegate?.chatState(state: state)
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
        log.warning("Error comes from Async", context: "Chat: DelegateComesFromAsync")
        delegate?.chatError(errorCode:      errorCode,
                            errorMessage:   errorMessage,
                            errorResult:    errorEvent)
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
        log.info("Async Ready", context: "Chat: DelegateComesFromAsync")
        handleAsyncReady()
    }
    
    
    // TODO: this delegate method should be delete, because it is not necessary
    public func asyncSendMessage(params: Any) {
        // this message is sends through Async
//        print("\n\n\n\n^^^^^^^^^^^^^^^^^\n^^^^^^^^^^^^^^^^^\nThis Message sends through Async: \n \(params)\n^^^^^^^^^^^^^^^^")
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
        log.verbose("content of received message: \n \(params)", context: "Chat")
        
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
        
        makeChatReady()
        
        stopGetUserInfoTimer()
        getUserInfoTimer = RepeatingTimer(timeInterval: Double(2))
    }
    
    func makeChatReady() {
        if userInfo == nil {
            getUserInfoRetryCount += 1
            getUserInfo(getCacheResponse: nil, uniqueId: { _ in }, completion: { (result) in
                let resultModel: GetUserInfoResponse = result as! GetUserInfoResponse
                log.verbose("get info result comes, and save userInfo: \n \(resultModel.returnDataAsJSON())", context: "Chat")

                if resultModel.hasError == false {
                    self.userInfo = User(withUserObject: resultModel.user)
                    self.isChatReady = true
                    self.delegate?.chatReady(withUserInfo: self.userInfo!)
                    if self.enableCache {
                        self.getAllThreads(withInputModel: GetAllThreadsRequest(summary: true, typeCode: nil))
                    }
                }
            }) { _ in }
        } else {
            getUserInfoRetryCount = 0
            isChatReady = true
            delegate?.chatReady(withUserInfo: userInfo!)
        }
    }
    
    
    /*
     * Handle ReceiveMessage From Async:
     *
     */
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
//        lastReceivedMessageTimer = nil
//        lastReceivedMessageTimer = RepeatingTimer(timeInterval: (Double(self.chatPingMessageInterval) * 1.5))
        
        stopLastReceivedMessageTimer()
        lastReceivedMessageTimer(interval: (Double(self.chatPingMessageInterval) * 1.5))
        
        let chatMessage = ChatMessage(withContent: withContent.content.convertToJSON())
        receivedMessageHandler(withContent: chatMessage)
    }
    
    
    func stopAllChatTimers() {
        stopTyping()
        stopGetUserInfoTimer()
        stopLastReceivedMessageTimer()
        stopLastSentMessageTimer()
    }
    
    func stopGetUserInfoTimer() {
        getUserInfoTimer = nil
    }
    
    func stopLastReceivedMessageTimer() {
        if let _ = lstRcvdMsgTimer {
            lstRcvdMsgTimer!.stop()
        }
    }
    
    func stopLastSentMessageTimer() {
        if let _ = lstSntMsgTimer {
            lstSntMsgTimer?.stop()
        }
    }
    
    
}



