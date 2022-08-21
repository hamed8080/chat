//
//  AsyncMessageEX.swift
//  FanapPodChatSDK
//
//  Created by hamed on 7/2/22.
//

import Foundation
import FanapPodAsyncSDK
extension AsyncMessage{
    
    var chatMessage:ChatMessage?{
        guard
            let chatMessageData = content?.data(using: .utf8),
            let chatMessage =  try? JSONDecoder().decode(ChatMessage.self, from: chatMessageData) else{return nil}
        return chatMessage
    }
}
