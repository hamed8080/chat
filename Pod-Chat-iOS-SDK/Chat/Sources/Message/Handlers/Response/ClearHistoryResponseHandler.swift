//
//  ClearHistoryResponseHandler.swift
//  Alamofire
//
//  Created by Hamed Hosseini on 2/26/21.
//

import Foundation
import FanapPodAsyncSDK

class ClearHistoryResponseHandler: ResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
		let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let threadId = try? JSONDecoder().decode(Int.self, from: data) else{return}
        callback(.init(uniqueId: chatMessage.uniqueId ,result: threadId))
        if let threadId = chatMessage.subjectId{
            CacheFactory.write(cacheType: .CLEAR_ALL_HISTORY(threadId))//no need to call save context becaudse use excute
        }
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CLEAR_HISTORY)
    }
}

