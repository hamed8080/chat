//
//  RemoveTagParticipantsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
import FanapPodAsyncSDK

class RemoveTagParticipantsResponseHandler: ResponseHandler {
	
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
		
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let tagParticipants = try? JSONDecoder().decode([TagParticipant].self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Tag(.init(tagParticipants: tagParticipants, type: .REMOVE_TAG_PARTICIPANT)))
        CacheFactory.write(cacheType: .DELETE_TAG_PARTICIPANTS(tagParticipants))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: tagParticipants))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId,requestType: .REMOVE_TAG_PARTICIPANTS)
	}
}
