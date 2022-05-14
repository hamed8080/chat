//
//  CloseThreadResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
import FanapPodAsyncSDK

class CloseThreadResponseHandler : ResponseHandler {
	
	static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		let chat = Chat.sharedInstance
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_CLOSED, chatMessage: chatMessage)))
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let threadId = chatMessage.subjectId else {return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: threadId))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CLOSE_THREAD)
	}
	
}
