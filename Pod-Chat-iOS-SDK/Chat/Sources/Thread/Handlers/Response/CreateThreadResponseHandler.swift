//
//  CreateThreadResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
import FanapPodAsyncSDK

class CreateThreadResponseHandler: ResponseHandler {
	
	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let newThread = try? JSONDecoder().decode(Conversation.self, from: data) else{return}        
        chat.delegate?.chatEvent(event: .Thread(.THREAD_NEW(newThread)))
		
        CacheFactory.write(cacheType: .THREADS([newThread]))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: newThread))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CREATE_THREAD)
	}
}
