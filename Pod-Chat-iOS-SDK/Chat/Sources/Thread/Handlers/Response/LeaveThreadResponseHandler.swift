//
//  LeaveThreadResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class LeaveThreadResponseHandler: ResponseHandler {


	static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_LEAVE_PARTICIPANT, chatMessage: chatMessage)))
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage)))
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let user = try? JSONDecoder().decode(User.self, from: data) else{return}
        guard let threadId = chatMessage.subjectId else {return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: user))
        CacheFactory.write(cacheType: .LEAVE_THREAD(threadId))
        PSM.shared.save()
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .LEAVE_THREAD)
	}
}
