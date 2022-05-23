//
//  AddParticipantResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
import FanapPodAsyncSDK

class AddParticipantResponseHandler: ResponseHandler {
	
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {

		let chat = Chat.sharedInstance
        
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let conversation = try? JSONDecoder().decode(Conversation.self, from: data) else{return}
        CacheFactory.write(cacheType: .PARTICIPANTS(conversation.participants, conversation.id))
        PSM.shared.save()
        chat.delegate?.chatEvent(event: .Thread(.THREAD_LAST_ACTIVITY_TIME(time: chatMessage.time, threadId: chatMessage.subjectId)))
        chat.delegate?.chatEvent(event: .Thread(.THREAD_ADD_PARTICIPANTS(thread:conversation, conversation.participants)))
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: conversation))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .ADD_PARTICIPANT)
	}
}