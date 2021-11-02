//
//  RemoveParticipantResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
import FanapPodAsyncSDK

class RemoveParticipantResponseHandler: ResponseHandler {
	
	static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {

		let chat = Chat.sharedInstance
        chat.delegate?.threadEvents(model: .init(type: .THREAD_REMOVE_PARTICIPANTS, chatMessage: chatMessage))
        chat.delegate?.threadEvents(model: .init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage))
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let participants = try? JSONDecoder().decode([Participant].self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId,result: participants))
        CacheFactory.write(cacheType: .REMOVE_PARTICIPANTS(participants: participants , threadId: chatMessage.subjectId))
        PSM.shared.save()
		chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)        
	}
}
