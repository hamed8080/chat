//
//  BlockedResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import FanapPodAsyncSDK

class BlockedResponseHandler {
	
	static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {

		let chat = Chat.sharedInstance
		
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let blockedResult = try? JSONDecoder().decode(BlockedContact.self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Contact(.BLOCKED(blockedResult, id: chatMessage.subjectId)))
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: blockedResult))        
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .BLOCK)
	}
}
