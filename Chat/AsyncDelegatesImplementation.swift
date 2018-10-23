//
//  AsyncDelegatesImplementation.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import Async
import SwiftyJSON



extension Chat: AsyncDelegates {
    
    public func asyncConnect(newPeerID: Int) {
        print("\n On Chat")
        print(":: \t DelegateComesFromAsync: Async Connected \n")
        peerId = newPeerID
        delegate?.chatConnected()
    }
    
    public func asyncDisconnect() {
        print("\n On Chat")
        print(":: \t DelegateComesFromAsync: Async Disconnected \n")
        oldPeerId = peerId
        peerId = nil
        delegate?.chatDisconnect()
    }
    
    public func asyncReconnect(newPeerID: Int) {
        print("\n On Chat")
        print(":: \t DelegateComesFromAsync: Async Reconnected \n")
        peerId = newPeerID
        delegate?.chatReconnect()
    }
    
    public func asyncStateChanged(socketState: Int, timeUntilReconnect: Int, deviceRegister: Bool, serverRegister: Bool, peerId: Int) {
        print("\n On Chat")
        print(":: DelegateComesFromAsync: Chat state changed:")
        print("socketState = \(socketState)")
        print("timeUntilReconnect = \(timeUntilReconnect)")
        print("deviceRegister = \(deviceRegister)")
        print("serverRegister = \(serverRegister)\n")
        
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
    
    public func asyncError(errorCode: Int, errorMessage: String, errorEvent: Any?) {
        print("\n On Chat")
        print(":: \t DelegateComesFromAsync: Error comes from Async \n")
        delegate?.chatError(errorCode: errorCode, errorMessage: errorMessage, errorResult: errorEvent)
    }
    
    public func asyncReady() {
        print("\n On Chat")
        print(":: \t DelegateComesFromAsync: Async Ready \n")
        handleAsyncReady()
    }
    
    public func asyncSendMessage(params: Any) {
        // this message is sends through Async
    }
    
    public func asyncReceiveMessage(params: JSON) {
        handleReceiveMessageFromAsync(params: params)
    }
    
    
    
    
    
    func handleAsyncReady() {
        print("\n On Chat")
        print(":: \t HandleAsyncReady \n")
        peerId = asyncClient?.asyncGetPeerId()
        if userInfo == nil {
            if (getUserInfoRetryCount < getUserInfoRetry) {
                getUserInfoRetryCount += 1
                getUserInfo(uniqueId: { (uniqueIdStr) in
                    // print(uniqueIdStr)
                }) { (result) in
                    let resultModel: UserInfoModel = result as! UserInfoModel
                    let resultJSON: JSON = resultModel.returnDataAsJSON()
                    
                    print("\n On Chat")
                    print(":: get info result comes, and save userInfo: \n \(resultJSON) \n")
                    
                    if resultJSON["hasError"].boolValue == false {
                        self.userInfo = resultJSON["result"]["user"]
                        self.chatState = true
                        self.delegate?.chatReady()
                    }
                }
            }
        }
    }
    
    
    func handleReceiveMessageFromAsync(params: JSON) {
        // checkout to keep async alive
        self.lastReceivedMessageTimeoutId?.suspend()
        DispatchQueue.global().async {
            self.lastReceivedMessageTime = Date()
            let myTimeInterval = Double(self.chatPingMessageInterval) * 1.5
            self.lastReceivedMessageTimeoutId = RepeatingTimer(timeInterval: myTimeInterval)
            self.lastReceivedMessageTimeoutId?.eventHandler = {
                if let lastReceivedMessageTimeBanged = self.lastReceivedMessageTime {
                    let elapsed = Date().timeIntervalSince(lastReceivedMessageTimeBanged)
                    let elapsedInt = Int(elapsed)
                    if (elapsedInt >= self.connectionCheckTimeout) {
                        DispatchQueue.main.async {
                            self.asyncClient?.asyncReconnectSocket()
                        }
                        self.lastReceivedMessageTimeoutId?.suspend()
                    }
                }
            }
            self.lastReceivedMessageTimeoutId?.resume()
        }
        
        pushMessageHandler(params: params)
    }
    
    
}
