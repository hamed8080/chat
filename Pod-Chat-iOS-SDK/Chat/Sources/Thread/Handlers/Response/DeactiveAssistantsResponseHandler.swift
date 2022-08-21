//
//  DeactiveAssistantsResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/23/21.
//

import Foundation
import FanapPodAsyncSDK

public class DeactiveAssistantsResponseHandler : ResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let assistants = try? JSONDecoder().decode([Assistant].self, from: data) else{return}
        chat.delegate?.chatEvent(event: .Assistant(.init(assistants: assistants, type: .DEACTIVE_ASSISTANTS)))
        CacheFactory.write(cacheType: .DELETE_ASSISTANTS(assistants))
        CacheFactory.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: assistants))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .DEACTICVE_ASSISTANT)
    }
    
}
