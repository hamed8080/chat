//
//  DeleteThreadResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class DeleteThreadResponseHandler: ResponseHandler {


	static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        guard let threadId = chatMessage.subjectId else {return}
        var participant:Participant? = nil
        if let data = chatMessage.content?.data(using: .utf8){
            participant = try? JSONDecoder().decode(Participant.self, from: data)
            chat.delegate?.chatEvent(event: .Thread(.THREAD_DELETED(threadId: threadId, participant: participant)))
            chat.delegate?.chatEvent(event: .Thread(.THREAD_LAST_ACTIVITY_TIME(time:chatMessage.time, threadId: chatMessage.subjectId)))
        }
        CacheFactory.write(cacheType: .DELETE_THREADS([threadId]))
        PSM.shared.save()
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: threadId))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .DELETE_THREAD)
	}
}
