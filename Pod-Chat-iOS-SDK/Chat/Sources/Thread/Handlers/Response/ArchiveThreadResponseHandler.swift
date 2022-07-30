//
//  ArchiveThreadResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
import FanapPodAsyncSDK

class ArchiveThreadResponseHandler: ResponseHandler {


	static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance
        guard let threadId = chatMessage.subjectId else {return}
        CacheFactory.write(cacheType: .ARCHIVE_UNARCHIVE_THREAD(true, threadId))
        PSM.shared.save()
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
		callback(.init(uniqueId: chatMessage.uniqueId ,result: threadId))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .ARCHIVE_THREAD)
	}
}
