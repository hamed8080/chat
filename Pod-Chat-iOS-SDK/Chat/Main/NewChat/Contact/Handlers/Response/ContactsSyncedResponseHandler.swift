//
//  ContactsSyncedResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/6/21.
//

import Foundation
import FanapPodAsyncSDK

class ContactsSyncedResponseHandler: ResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
		let chat = Chat.sharedInstance
        CacheFactory.write(cacheType: .SYNCED_CONTACTS)
        CacheFactory.save()
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
    }
}
