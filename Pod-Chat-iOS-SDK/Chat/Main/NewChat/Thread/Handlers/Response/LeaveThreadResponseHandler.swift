//
//  LeaveThreadResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class LeaveThreadResponseHandler: ResponseHandler {


	static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
		
		let chat = Chat.sharedInstance
        chat.delegate?.threadEvents(model: .init(type: .THREAD_LEAVE_PARTICIPANT, chatMessage: chatMessage))
        chat.delegate?.threadEvents(model: .init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage))
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let conversation = try? JSONDecoder().decode(Conversation.self, from: data) else{return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: conversation))
        CacheFactory.write(cacheType: .LEAVE_THREAD(conversation))
        PSM.shared.save()
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .LEAVE_THREAD)
	}
}
