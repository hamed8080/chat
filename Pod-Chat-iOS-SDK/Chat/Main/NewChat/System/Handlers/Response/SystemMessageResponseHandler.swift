//
//  SystemMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/28/21.
//

import Foundation
import FanapPodAsyncSDK
import FanapPodAsyncSDK

class SystemMessageResponseHandler : ResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
		
		let chat = Chat.sharedInstance
        log.verbose("Message of type 'SYSTEM_MESSAGE' revieved", context: "Chat")
        if let data = chatMessage.content?.data(using: .utf8) , let eventMessageModel = try? JSONDecoder().decode(SystemEventMessageModel.self, from: data ){
            chat.delegate?.systemEvents(model: .init(type: eventMessageModel.smt, time: chatMessage.time, threadId: chatMessage.subjectId, user: eventMessageModel))
        }
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .SYSTEM_MESSAGE)
    }
    
}
