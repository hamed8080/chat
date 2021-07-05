//
//  StartCallRequestResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation


class StartCallRequestResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let deliverCallRequest = try? JSONDecoder().decode(DeliverCallRequest.self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: deliverCallRequest))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
    }
}
