//
//  AddParticipantResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
import FanapPodAsyncSDK

class AddParticipantResponseHandler: ResponseHandler {
	
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {

		let chat = Chat.sharedInstance
        chat.delegate?.threadEvents(model: .init(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage))
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let conversation = try? JSONDecoder().decode(Conversation.self, from: data) else{return}
		callback(.init(uniqueId:chatMessage.uniqueId , result: conversation))
        CacheFactory.write(cacheType: .PARTICIPANTS(conversation.participants, conversation.id))
        PSM.shared.save()
        chat.delegate?.threadEvents(model: .init(type: .THREAD_ADD_PARTICIPANTS, chatMessage: chatMessage , participants: conversation.participants))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
	}
}
