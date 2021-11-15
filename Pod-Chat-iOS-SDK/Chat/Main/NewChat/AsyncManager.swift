//
//  AsyncManager.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import FanapPodAsyncSDK

internal class AsyncManager: NewAsyncDelegate{
    
    private (set) var asyncClient               :NewAsync?
    private var lastSentMessageDate             :Date?                          = Date()
    private (set) var chatServerPingTimer       :Timer?                         = nil

    public init(){
        
    }
    
    public func createAsync() {
        if let chatConfig = Chat.sharedInstance.config{
            let asyncConfig = AsyncConfig(socketAddress: chatConfig.socketAddress,
                                          serverName: chatConfig.serverName,
                                          deviceId: chatConfig.deviceId ?? UUID().uuidString,
                                          appId: "PodChat",
                                          peerId: nil,
                                          messageTtl: chatConfig.messageTtl,
                                          connectionRetryInterval: TimeInterval(chatConfig.connectionRetryInterval),
                                          connectionCheckTimeout: TimeInterval(chatConfig.connectionCheckTimeout),
                                          reconnectCount: chatConfig.reconnectCount,
                                          reconnectOnClose: chatConfig.reconnectOnClose,
                                          isDebuggingLogEnabled: chatConfig.isDebuggingAsyncEnable)
            asyncClient = NewAsync(config: asyncConfig, delegate: self)
            asyncClient?.createSocket()
        }
    }
    
    public func asyncMessage(asyncMessage: NewAsyncMessage){
        ReceiveMessageFactory.invokeCallback(asyncMessage: asyncMessage)
        
        // FIXME:  needs to Map webrtcPeerIds With ServerNames like["KuretoAdmin1":13631820 , "KuretoAdmin2":13631821 ,...]
        let webrtcSenderPeerIds:[Int64] =  [13631820,13631821,101130994,101131106,101131185]
        let webrtcPeerNames     =  ["KuretoAdmin1,KuretoAdmin2"]
        
        if webrtcSenderPeerIds.contains(asyncMessage.senderId ?? 0) || webrtcPeerNames.contains(asyncMessage.peerName ?? ""){
            //call webrtc
            WebRTCClientNew.instance?.messageReceived(asyncMessage)
            return
        }
    }
    
    public func asyncStateChanged(asyncState: AsyncSocketState, error: AsyncError?) {
        Chat.sharedInstance.delegate?.chatState(state: asyncState.chatState, currentUser: nil, error: error?.chatError)
        if asyncState == .ASYNC_READY{
            UserInfoRequestHandler.getUserForChatReady()
        }else if asyncState == .CLOSED{
            chatServerPingTimer?.invalidate()
        }
    }
    
    public func asyncMessageSent(message: Data) {
        ///nothing to do it's usefel when some client directly use async SDK
    }
    
    public func asyncError(error: AsyncError) {
        Chat.sharedInstance.delegate?.chatError(error: .init(code: .ASYNC_ERROR, message: error.message, userInfo: error.userInfo, rawError: error.rawError))
    }
    
    public func disposeObject(){
        asyncClient?.disposeObject()
        asyncClient = nil
        chatServerPingTimer?.invalidate()
        chatServerPingTimer = nil
    }
    
    public func sendData(type: AsyncMessageTypes, data: Data){
        asyncClient?.sendData(type: type, data: data)
        sendPingTimer()
    }
    
    internal func sendPingTimer(){
        chatServerPingTimer?.invalidate()
        chatServerPingTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) {[weak self] timer in
            guard let self = self else{return}
            if let lastSentMessageDate = self.lastSentMessageDate , Date().timeIntervalSince1970 - (lastSentMessageDate.timeIntervalSince1970 + 20) > 20{
                self.sendChatServerPing()
            }
        }
    }
    
    ///It's differ from ping in async SDK you need to send ping to chat server to chat server to keep peerId
    ///If you don't send ping to chat server it clear peerId within 30s to 1 minute and chat server cannot send messages to client like new chat inside thread
    private func sendChatServerPing(){
        Chat.sharedInstance.prepareToSendAsync(messageType: .PING)
    }
    
}
