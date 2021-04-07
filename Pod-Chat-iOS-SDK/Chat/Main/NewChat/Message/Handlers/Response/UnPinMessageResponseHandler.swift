//
//  UnPinMessageResponseHandler.swift
//  Alamofire
//
//  Created by Hamed Hosseini on 2/26/21.
//

import Foundation

class UnPinMessageResponseHandler: ResponseHandler {
    
    static func handle(_ chat: Chat, _ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        chat.delegate?.threadEvents(model: ThreadEventModel(type: .MESSAGE_UNPIN, chatMessage: chatMessage))
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let pinResponse = try? JSONDecoder().decode(PinUnpinMessage.self, from: data) else{return}
        callback(.init(uniqueId:chatMessage.uniqueId , result: pinResponse))
        CacheFactory.write(cacheType: .UNPIN_MESSAGE(pinResponse, chatMessage.subjectId))
        PSM.shared.save()
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId)
    }
}

