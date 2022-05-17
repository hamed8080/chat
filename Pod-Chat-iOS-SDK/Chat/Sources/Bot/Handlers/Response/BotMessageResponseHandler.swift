//
//  BotMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/14/21.
//

import Foundation
import FanapPodAsyncSDK

class BotMessageResponseHandler: ResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		let chat = Chat.sharedInstance
        chat.delegate?.chatEvent(event: .Bot(.init(type: .BOT_MESSAGE, message: chatMessage.content)))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .BOT_MESSAGE)
    }
}
