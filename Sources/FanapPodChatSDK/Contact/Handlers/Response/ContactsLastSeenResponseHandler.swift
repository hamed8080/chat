//
//  ContactsLastSeenResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import FanapPodAsyncSDK

class ContactsLastSeenResponseHandler {
	
	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let users = try? JSONDecoder().decode([UserLastSeenDuration].self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Contact(.CONTACTS_LAST_SEEN(users)))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CONTACTS_LAST_SEEN)
	}
}
