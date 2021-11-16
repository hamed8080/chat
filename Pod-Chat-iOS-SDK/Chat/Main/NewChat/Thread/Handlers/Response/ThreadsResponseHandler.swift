//
//  ThreadsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class ThreadsResponseHandler: ResponseHandler {


	static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
		
		let chat = Chat.sharedInstance
        chat.delegate?.threadEvents(model: .init(type: .THREADS_LIST_CHANGE, chatMessage: chatMessage))
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let conversations = try? JSONDecoder().decode([Conversation].self, from: data) else{return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: conversations,contentCount: chatMessage.contentCount ?? 0))
		CacheFactory.write(cacheType: .THREADS(conversations))
		PSM.shared.save()
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .GET_THREADS)
		
	}
}
