//
//  ThreadsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class ThreadsResponseHandler: ResponseHandler {


	static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREADS_LIST_CHANGE, chatMessage: chatMessage)))
		
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let conversations = try? JSONDecoder().decode([Conversation].self, from: data) else{return}
        
		CacheFactory.write(cacheType: .THREADS(conversations))
		PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: conversations,contentCount: chatMessage.contentCount ?? 0))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .GET_THREADS)
		
	}
}
