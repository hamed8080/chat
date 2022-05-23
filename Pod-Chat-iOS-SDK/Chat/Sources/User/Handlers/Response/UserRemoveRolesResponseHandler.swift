//
//  UserRemoveRolesResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/7/21.
//

import Foundation
import FanapPodAsyncSDK

class UserRemoveRolesResponseHandler: ResponseHandler {
    
    static func handle(_ chatMessage: ChatMessage, _ asyncMessage: AsyncMessage) {
        
		let chat = Chat.sharedInstance
        
        guard let threadId = chatMessage.subjectId else {return}
        chat.delegate?.chatEvent(event: .Thread(.THREAD_LAST_ACTIVITY_TIME(time: chatMessage.time, threadId: threadId)))
        
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let usersAndRoles = try? JSONDecoder().decode([UserRole].self, from: data) else {return}
        chat.delegate?.chatEvent(event: .Thread(.THREAD_USER_ROLE(threadId: threadId, roles: usersAndRoles)))
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId: chatMessage.uniqueId ,result: usersAndRoles))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .REMOVE_ROLE_FROM_USER)
    }
}
