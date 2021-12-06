//
//  ThreadParticipantsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
import FanapPodAsyncSDK

class ThreadParticipantsResponseHandler : ResponseHandler{
	
	static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
		
		let chat = Chat.sharedInstance
        chat.delegate?.threadEvents(model: .init(type: .THREAD_PARTICIPANTS_LIST_CHANGE, chatMessage: chatMessage))
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let participants = try? JSONDecoder().decode([Participant].self, from: data) else{return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: participants , contentCount: chatMessage.contentCount ?? 0))
        CacheFactory.write(cacheType: .PARTICIPANTS(participants, chatMessage.subjectId))
        PSM.shared.save()
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .THREAD_PARTICIPANTS)
	}
}
