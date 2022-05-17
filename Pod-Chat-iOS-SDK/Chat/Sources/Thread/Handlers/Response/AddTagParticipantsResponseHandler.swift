//
//  AddTagParticipantsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
import FanapPodAsyncSDK

class AddTagParticipantsResponseHandler: ResponseHandler {
	
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {

		let chat = Chat.sharedInstance
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let tagParticipants = try? JSONDecoder().decode([TagParticipant].self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Tag(.init(tagParticipants:tagParticipants, type: .ADD_TAG_PARTICIPANT)))
        if let tagId  = chatMessage.subjectId{
            CacheFactory.write(cacheType: .TAG_PARTICIPANTS(tagParticipants , tagId))
        }
        PSM.shared.save()        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: tagParticipants))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .ADD_TAG_PARTICIPANTS)
	}
}
