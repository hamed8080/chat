//
//  CallCanceledResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
import FanapPodAsyncSDK

fileprivate let CANCELED_CALL_NAME        = "CANCELED_CALL_NAME"
public var CANCELED_CALL_NAME_OBJECT = Notification.Name.init(CANCELED_CALL_NAME)

class CallCanceledResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let call = try? JSONDecoder().decode(Call.self, from: data) else{return}
        chat.callbacksManager.callRejectedDelegate?(call,chatMessage.uniqueId)
        NotificationCenter.default.post(name: CANCELED_CALL_NAME_OBJECT ,object: call)
    }
}
