//
//  AllUnreadMessageCountResponseHandler.swift
//  Alamofire
//
//  Created by Hamed Hosseini on 2/26/21.
//

import Foundation

class AllUnreadMessageCountResponseHandler: ResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
		
		let chat = Chat.sharedInstance
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let unreadCount = try? JSONDecoder().decode(Int.self, from: data) else{return}
        callback(.init(uniqueId: chatMessage.uniqueId , result: unreadCount))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
    }
}

