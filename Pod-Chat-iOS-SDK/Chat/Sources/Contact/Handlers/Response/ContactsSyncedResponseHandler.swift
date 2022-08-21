//
//  ContactsSyncedResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/6/21.
//

import Foundation
import FanapPodAsyncSDK

class ContactsSyncedResponseHandler: ResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        CacheFactory.write(cacheType: .SYNCED_CONTACTS)
        CacheFactory.save()
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CONTACT_SYNCED)
    }
}
