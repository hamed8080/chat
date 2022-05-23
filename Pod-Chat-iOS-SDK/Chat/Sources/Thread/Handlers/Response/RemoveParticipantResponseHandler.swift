//
//  RemoveParticipantResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
import FanapPodAsyncSDK

class RemoveParticipantResponseHandler: ResponseHandler {
	
	static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {

		let chat = Chat.sharedInstance
        
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let participants = try? JSONDecoder().decode([Participant].self, from: data) else{return}
        CacheFactory.write(cacheType: .REMOVE_PARTICIPANTS(participants: participants , threadId: chatMessage.subjectId))
        PSM.shared.save()
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_REMOVE_PARTICIPANTS, chatMessage: chatMessage, participants: participants)))
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage,participants: participants)))
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId,result: participants))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .REMOVE_PARTICIPANT)        
	}
}
