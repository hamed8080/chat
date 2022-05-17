//
//  CreateThreadResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
import FanapPodAsyncSDK

class CreateThreadResponseHandler: ResponseHandler {
	
	static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_NEW, chatMessage: chatMessage)))
		
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let newThread = try? JSONDecoder().decode(Conversation.self, from: data) else{return}
        CacheFactory.write(cacheType: .THREADS([newThread]))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: newThread))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CREATE_THREAD)
	}
}
