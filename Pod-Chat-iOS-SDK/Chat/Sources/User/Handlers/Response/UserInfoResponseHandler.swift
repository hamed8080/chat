//
//  UserInfoResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
import FanapPodAsyncSDK

class UserInfoResponseHandler: ResponseHandler{
	
	static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        chat.delegate?.chatEvent(event: .System(.SERVER_TIME(chatMessage.time)))
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let user = try? JSONDecoder().decode(User.self, from: data) else {return}
        CacheFactory.write(cacheType: .USER_INFO(user))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: user))        
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .USER_INFO)
	}
}
