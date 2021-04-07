//
//  CreateThreadResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
class CreateThreadResponseHandler: ResponseHandler {
	
	static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        
        chat.delegate?.threadEvents(model: .init(type: .THREAD_NEW, chatMessage: chatMessage))
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let newThread = try? JSONDecoder().decode(Conversation.self, from: data) else{return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: newThread))
        CacheFactory.write(cacheType: .THREADS([newThread]))
        PSM.shared.save()
		chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
	}
}
