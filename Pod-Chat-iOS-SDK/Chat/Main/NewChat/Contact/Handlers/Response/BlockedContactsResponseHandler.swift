//
//  BlockedContactsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/16/21.
//

import Foundation
class BlockedContactsResponseHandler: ResponseHandler {
    
    
    static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let blockedContacts = try? JSONDecoder().decode([BlockedUser].self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: blockedContacts))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
    }
    
}
