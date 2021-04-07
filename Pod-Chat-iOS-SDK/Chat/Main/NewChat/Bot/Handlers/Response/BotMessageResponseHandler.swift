//
//  BotMessageResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/14/21.
//

import Foundation
class BotMessageResponseHandler: ResponseHandler {
    
    static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        chat.delegate?.botEvents(model: .init(type: .BOT_MESSAGE, message:chatMessage.content))
    }
}
