//
//  CurrentUserRolesResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class CurrentUserRolesResponseHandler: ResponseHandler {


	static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: NewAsyncMessage) {
		
		let chat = Chat.sharedInstance
		guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		guard let data = chatMessage.content?.data(using: .utf8) else {return}
		guard let userRoles = try? JSONDecoder().decode([Roles].self, from: data) else{return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: userRoles))
        CacheFactory.write(cacheType: .CURRENT_USER_ROLES( userRoles , chatMessage.subjectId))
        PSM.shared.save()
		chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
	}
}
