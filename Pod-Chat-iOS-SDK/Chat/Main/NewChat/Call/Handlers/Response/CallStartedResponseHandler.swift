//
//  CallStartedResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

class CallStartedResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let callStarted = try? JSONDecoder().decode(StartCall.self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: callStarted))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
    }
}
