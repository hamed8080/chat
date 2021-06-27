//
//  RemoveTagParticipantsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
class RemoveTagParticipantsResponseHandler: ResponseHandler {
	
	static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {

		let chat = Chat.sharedInstance
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let tagParticipants = try? JSONDecoder().decode([TagParticipant].self, from: data) else{return}
		callback(.init(uniqueId:chatMessage.uniqueId , result: tagParticipants))
        CacheFactory.write(cacheType: .DELETE_TAG_PARTICIPANTS(tagParticipants))
        PSM.shared.save()
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
	}
}
