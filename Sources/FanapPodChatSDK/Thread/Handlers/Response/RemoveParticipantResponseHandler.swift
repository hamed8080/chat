//
//  RemoveParticipantResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
import FanapPodAsyncSDK

class RemoveParticipantResponseHandler: ResponseHandler {
	
	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let participants = try? JSONDecoder().decode([Participant].self, from: data) else{return}
        CacheFactory.write(cacheType: .REMOVE_PARTICIPANTS(participants: participants , threadId: chatMessage.subjectId))
        PSM.shared.save()
        chat.delegate?.chatEvent(event: .Thread(.THREAD_REMOVE_PARTICIPANTS(participants)))
        chat.delegate?.chatEvent(event: .Thread(.THREAD_LAST_ACTIVITY_TIME(time: chatMessage.time, threadId:chatMessage.subjectId)))
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId,result: participants))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .REMOVE_PARTICIPANT)        
	}
}
