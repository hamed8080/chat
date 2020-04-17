//
//  ChatFullStateModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 1/30/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class ChatFullStateModel {
    
    var socketState:        AsyncStateType
    var timeUntilReconnect: Int
    var deviceRegister:     Bool
    var serverRegister:     Bool
    var peerId:             Int
    
    public init(socketState:        AsyncStateType,
                timeUntilReconnect: Int,
                deviceRegister:     Bool,
                serverRegister:     Bool,
                peerId:             Int) {
        self.socketState        = socketState
        self.timeUntilReconnect = timeUntilReconnect
        self.deviceRegister     = deviceRegister
        self.serverRegister     = serverRegister
        self.peerId             = peerId
    }
    
}
