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
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        if let data = chatMessage.content?.data(using: .utf8) , let eventMessageModel = try? JSONDecoder().decode(SystemEventMessageModel.self, from: data ){
            chat.delegate?.chatEvent(event: .System(.init(type: eventMessageModel.smt, time: chatMessage.time, threadId: chatMessage.subjectId, user: eventMessageModel)))
        }
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .SYSTEM_MESSAGE)
    }
    
}
