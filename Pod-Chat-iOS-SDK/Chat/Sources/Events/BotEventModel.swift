//
//  BotEventModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//


import Foundation

open class BotEventModel {
    
    public let type:    BotEventTypes
    public let message: Any?
    
    init(type: BotEventTypes, message: Any?) {
        self.type       = type
        self.message    = message
    }
    
}

public enum BotEventTypes {
    case BOT_MESSAGE
}
