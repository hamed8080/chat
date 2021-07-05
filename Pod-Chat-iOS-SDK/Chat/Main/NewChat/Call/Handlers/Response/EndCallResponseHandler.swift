//
//  EndCallResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation


class EndCallResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: chatMessage.subjectId))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
    }
}
