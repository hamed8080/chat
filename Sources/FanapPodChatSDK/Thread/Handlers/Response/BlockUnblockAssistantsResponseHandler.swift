//
//  BlockUnblockAssistantsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/23/21.
//

import Foundation
import FanapPodAsyncSDK

public class BlockUnblockAssistantsResponseHandler : ResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let assistants = try? JSONDecoder().decode([Assistant].self, from: data) else{return}
        CacheFactory.write(cacheType: .INSERT_OR_UPDATE_ASSISTANTS(assistants))
        CacheFactory.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: assistants))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .BLOCK_ASSISTANT)
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .UNBLOCK_ASSISTANT)
    }
}
