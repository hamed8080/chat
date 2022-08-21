//
//  BotMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/14/21.
//

import Foundation
import FanapPodAsyncSDK

class BotMessageResponseHandler: ResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        chat.delegate?.chatEvent(event: .Bot(.BOT_MESSAGE(chatMessage.content)))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .BOT_MESSAGE)
    }
}
