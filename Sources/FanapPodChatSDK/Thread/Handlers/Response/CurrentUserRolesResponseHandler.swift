//
//  CurrentUserRolesResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class CurrentUserRolesResponseHandler: ResponseHandler {


	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
		
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let userRoles = try? JSONDecoder().decode([Roles].self, from: data) else{return}
        chat.delegate?.chatEvent(event: .User(.ROLES(userRoles, id:chatMessage.subjectId)))
        CacheFactory.write(cacheType: .CURRENT_USER_ROLES( userRoles , chatMessage.subjectId))
        PSM.shared.save()
        
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId: chatMessage.uniqueId ,result: userRoles))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .GET_CURRENT_USER_ROLES)
	}
}
