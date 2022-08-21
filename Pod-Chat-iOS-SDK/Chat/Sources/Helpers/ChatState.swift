//
//  ChatState.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation
import FanapPodAsyncSDK
public enum ChatState:String{
    case CONNECTING  = "CONNECTING"
    case CONNECTED   = "CONNECTED"
    case CLOSED      = "CLOSED"
    case ASYNC_READY = "ASYNC_READY"
    case CHAT_READY  = "CHAT_READY"
}

extension AsyncSocketState{
    
    var chatState:ChatState{
        return ChatState(rawValue: rawValue) ?? ChatState.CLOSED
    }
}
