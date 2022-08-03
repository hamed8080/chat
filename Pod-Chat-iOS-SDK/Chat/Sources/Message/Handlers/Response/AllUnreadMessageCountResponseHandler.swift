//
//  AllUnreadMessageCountResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/26/21.
//

import Foundation
import FanapPodAsyncSDK

class AllUnreadMessageCountResponseHandler: ResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let unreadCount = try? JSONDecoder().decode(Int.self, from: data) else{return}
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: unreadCount))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .ALL_UNREAD_MESSAGE_COUNT)
    }
}

