//
//  ThreadsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class ThreadsResponseHandler: ResponseHandler {

	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let conversations = try? JSONDecoder().decode([Conversation].self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Thread(.THREADS_LIST_CHANGE(conversations)))
        
		CacheFactory.write(cacheType: .THREADS(conversations))
		PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: conversations,contentCount: chatMessage.contentCount ?? 0))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .GET_THREADS)
		
	}
}
