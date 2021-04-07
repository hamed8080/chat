//
//  ContactsSyncedResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/6/21.
//

import Foundation
class ContactsSyncedResponseHandler: ResponseHandler {
    
    static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        CacheFactory.write(cacheType: .SYNCED_CONTACTS)
        CacheFactory.save()
    }
}
