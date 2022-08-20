//
//  CustomerInfoResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/7/21.
//

import Foundation
import FanapPodAsyncSDK

class CustomerInfoResponseHandler: ResponseHandler {
    
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else {return}
		let chat = Chat.sharedInstance        

        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let cutomerInfo = try? JSONDecoder().decode(CustomerInfo.self, from: data) else {return}

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId)else {return}
        callback(.init(uniqueId: chatMessage.uniqueId ,result: cutomerInfo))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .CUSTOMER_INFO)
    }
}
