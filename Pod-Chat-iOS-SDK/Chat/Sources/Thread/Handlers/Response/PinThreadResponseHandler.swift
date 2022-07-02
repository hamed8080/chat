//
//  PinThreadResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class PinThreadResponseHandler: ResponseHandler {


	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
		
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let threadId = try? JSONDecoder().decode(Int.self, from: data) else{return}
        if chatMessage.type == .PIN_THREAD{
            chat.delegate?.chatEvent(event: .Thread(.THREAD_PIN(threadId: threadId)))
        }else if chatMessage.type == .UNPIN_THREAD{
            chat.delegate?.chatEvent(event: .Thread(.THREAD_UNPIN(threadId: threadId)))
        }
        
        let resposne = PinThreadResponse(threadId: threadId)
        CacheFactory.write(cacheType: .PIN_UNPIN_THREAD(threadId))
        CacheFactory.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: resposne))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .PIN_THREAD)
	}
}
