//
//  CallRejectedResponseHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation


fileprivate let REJECTED_CALL_NAME        = "REJECTED_CALL_NAME"
public var REJECTED_CALL_NAME_OBJECT = Notification.Name.init(REJECTED_CALL_NAME)

class CallRejectedResponseHandler {
    
    static func handle(_ chatMessage: NewChatMessage, _ asyncMessage: AsyncMessage) {
        
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else {return}
        guard let call = try? JSONDecoder().decode(Call.self, from: data) else{return}
        chat.callbacksManager.callRejectedDelegate?(call,chatMessage.uniqueId)
        NotificationCenter.default.post(name: REJECTED_CALL_NAME_OBJECT ,object: call)
    }
}
