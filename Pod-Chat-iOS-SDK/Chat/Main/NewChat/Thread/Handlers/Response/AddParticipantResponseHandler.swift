//
//  AddParticipantResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
class AddParticipantResponseHandler: ResponseHandler {
	
	static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {

        chat.delegate?.threadEvents(model: .init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage))
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let conversation = try? JSONDecoder().decode(Conversation.self, from: data) else{return}
		callback(.init(uniqueId:chatMessage.uniqueId , result: conversation))
        CacheFactory.write(cacheType: .PARTICIPANTS(conversation.participants, conversation.id))
        PSM.shared.save()
		chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
        chat.delegate?.threadEvents(model: .init(type: .THREAD_ADD_PARTICIPANTS, chatMessage: chatMessage , participants: conversation.participants))
	}
}
