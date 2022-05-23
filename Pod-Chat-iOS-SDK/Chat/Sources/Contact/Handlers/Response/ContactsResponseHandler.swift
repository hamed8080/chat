//
//  ContactsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/16/21.
//

import Foundation
import FanapPodAsyncSDK

class ContactsResponseHandler: ResponseHandler {
    
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
		let chat = Chat.sharedInstance
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let contacts = try? JSONDecoder().decode([Contact].self, from: data) else{return}
        CacheFactory.write(cacheType: .CASHE_CONTACTS(contacts))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else {return}
        callback(.init(uniqueId: chatMessage.uniqueId ,result: contacts , contentCount: chatMessage.contentCount ?? contacts.count))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .GET_CONTACTS)
    }
    
}
