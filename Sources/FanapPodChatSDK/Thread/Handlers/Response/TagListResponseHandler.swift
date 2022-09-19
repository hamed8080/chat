//
//  DeleteTagResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
import FanapPodAsyncSDK

class TagListResponseHandler: ResponseHandler {
	
	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
		
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let tags = try? JSONDecoder().decode([Tag].self, from: data) else{return}
		
        CacheFactory.write(cacheType: .TAGS(tags))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: tags))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId,requestType: .TAG_LIST)
	}
}
