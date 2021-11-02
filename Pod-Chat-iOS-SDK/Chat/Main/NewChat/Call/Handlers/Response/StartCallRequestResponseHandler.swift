//
//  StartCallRequestResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let RECEIVE_CALL_NAME        = "RECEIVE_CALL_NAME"
public var RECEIVE_CALL_NAME_OBJECT = Notification.Name.init(RECEIVE_CALL_NAME)

class StartCallRequestResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let createCall = try? JSONDecoder().decode(CreateCall.self, from: data) else{return}
		chat.callbacksManager.callRequestArriveDelegate?(createCall)
		NotificationCenter.default.post(name: RECEIVE_CALL_NAME_OBJECT ,object: createCall)
    }
}
