//
//  ThreadParticipantsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
import FanapPodAsyncSDK

class ThreadParticipantsResponseHandler : ResponseHandler{
	
	static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let participants = try? JSONDecoder().decode([Participant].self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Thread(.THREAD_PARTICIPANTS_LIST_CHANGE(threadId: chatMessage.subjectId, participants)))
        CacheFactory.write(cacheType: .PARTICIPANTS(participants, chatMessage.subjectId))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: participants , contentCount: chatMessage.contentCount ?? 0))
        
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .THREAD_PARTICIPANTS)
	}
}
