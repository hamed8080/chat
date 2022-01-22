//
//  BatchAddContactsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/16/21.
//

import Foundation
import FanapPodAsyncSDK

class BatchAddContactsResponseHandler: ResponseHandler {
    
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
		let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let batchContactsResponse = try? JSONDecoder().decode(NewContactResponse.self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: batchContactsResponse))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .ADD_CONTACT)
    }
    
}
