//
//  ContactNotSeenDurationHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/16/21.
//

import Foundation
class ContactNotSeenDurationHandler: ResponseHandler {
    
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        
		let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let contacts = try? JSONDecoder().decode(ContactNotSeenDurationRespoonse.self, from: data) else{return}
        callback(.init(uniqueId: chatMessage.uniqueId, result: contacts))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
    }
}
