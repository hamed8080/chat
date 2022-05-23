//
//  BotEventModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//


import Foundation

open class BotEventModel {
    
    public let type:    BotEventTypes
    public let bot: Bot?
    public let botName:String?
    public let botInfo: BotInfo?
    public let message: String?
    
    init(type: BotEventTypes, bot:Bot? = nil, botName:String? = nil, botInfo: BotInfo? = nil, message:String? = nil) {
        self.type       = type
        self.botInfo    = botInfo
        self.bot        = bot
        self.message    = message
        self.botName    = botName
    }
    
}

public enum BotEventTypes {
    case CREATE_BOT
    case BOT_MESSAGE
    case CREATE_BOT_COMMAND
    case REMOVE_BOT_COMMAND
    case START_BOT
    case STOP_BOT
}
