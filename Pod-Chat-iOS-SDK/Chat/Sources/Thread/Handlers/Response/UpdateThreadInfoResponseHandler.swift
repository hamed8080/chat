//
//  UpdateThreadInfoResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/23/21.
//

import Foundation
import FanapPodAsyncSDK
import Alamofire


public class UpdateThreadInfoResponseHandler : ResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		let chat = Chat.sharedInstance
        chat.delegate?.chatEvent(event: .Thread(.init(type: .THREAD_INFO_UPDATED, chatMessage: chatMessage)))
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let conversation = try? JSONDecoder().decode(Conversation.self, from: data) else{return}
        
        CacheFactory.write(cacheType: .THREADS([conversation]))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: conversation))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .THREAD_INFO_UPDATED)
    }
    
}
