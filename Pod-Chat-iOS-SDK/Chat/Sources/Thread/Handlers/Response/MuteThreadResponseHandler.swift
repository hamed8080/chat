//
//  MuteThreadResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class MuteThreadResponseHandler: ResponseHandler {


	static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
		let chat = Chat.sharedInstance
        
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let threadId = try? JSONDecoder().decode(Int.self, from: data) else{return}
        if chatMessage.type == . MUTE_THREAD{
            chat.delegate?.chatEvent(event: .Thread(.THREAD_MUTE(threadId: threadId)))
        }else if chatMessage.type == .UNMUTE_THREAD{
            chat.delegate?.chatEvent(event: .Thread(.THREAD_UNMUTE(threadId: threadId)))
        }
        
        let resposne = MuteThreadResponse(threadId: threadId)
        
        CacheFactory.write(cacheType: .MUTE_UNMUTE_THREAD(threadId))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		callback(.init(uniqueId:chatMessage.uniqueId , result: resposne))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .MUTE_THREAD)
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .UNMUTE_THREAD)
        
	}
}
