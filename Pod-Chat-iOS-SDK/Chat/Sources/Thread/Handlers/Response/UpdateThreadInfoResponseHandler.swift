//
//  UpdateThreadInfoResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/23/21.
//

import Foundation
import FanapPodAsyncSDK

public class UpdateThreadInfoResponseHandler : ResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let conversation = try? JSONDecoder().decode(Conversation.self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Thread(.THREAD_INFO_UPDATED(conversation)))
        
        CacheFactory.write(cacheType: .THREADS([conversation]))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: conversation))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .THREAD_INFO_UPDATED)
    }
    
}
