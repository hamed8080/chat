//
//  SpamPvThreadResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/11/21.
//

import Foundation
class SpamPvThreadResponseHandler: ResponseHandler {

    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let blockedUser = try? JSONDecoder().decode(BlockedUser.self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: blockedUser))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
    }
}
