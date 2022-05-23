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
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let user = try? JSONDecoder().decode(User.self, from: data) else{return}
        
        chat.delegate?.chatEvent(event: .Thread(.THREAD_LEAVE_PARTICIPANT(user)))
        chat.delegate?.chatEvent(event: .Thread(.THREAD_LAST_ACTIVITY_TIME(time:chatMessage.time, threadId: chatMessage.subjectId)))
        
        guard let threadId = chatMessage.subjectId else {return}
        CacheFactory.write(cacheType: .LEAVE_THREAD(threadId))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		
        
		callback(.init(uniqueId: chatMessage.uniqueId ,result: user))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .LEAVE_THREAD)
	}
}
