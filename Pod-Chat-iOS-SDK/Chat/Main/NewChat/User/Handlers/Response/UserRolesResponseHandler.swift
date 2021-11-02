//
//  UserRolesResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/7/21.
//

import Foundation
import FanapPodAsyncSDK

class UserRolesResponseHandler: ResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
        
		let chat = Chat.sharedInstance
        let adminEvent = ThreadEventModel(type: .THREAD_ADD_ADMIN, chatMessage: chatMessage)
        chat.delegate?.threadEvents(model: adminEvent)
        let lastActivityEvent = ThreadEventModel(type: .THREAD_LAST_ACTIVITY_TIME, chatMessage: chatMessage)
        chat.delegate?.threadEvents(model: lastActivityEvent)
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let usersAndRoles = try? JSONDecoder().decode([UserRole].self, from: data) else {return}
        callback(.init(uniqueId: chatMessage.uniqueId ,result: usersAndRoles))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
    }
}
