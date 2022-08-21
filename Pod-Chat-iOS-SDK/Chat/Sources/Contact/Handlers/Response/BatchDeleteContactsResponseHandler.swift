//
//  BatchDeleteContactsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/16/21.
//

import Foundation
import FanapPodAsyncSDK

class BatchDeleteContactsResponseHandler: ResponseHandler {
    
    
    static func handle(_ asyncMessage: AsyncMessage) {

        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let batchDeleteContactsResponse = try? JSONDecoder().decode(RemoveContactResponse.self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: batchDeleteContactsResponse))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .REMOVE_CONTACTS)
    }
    
}
