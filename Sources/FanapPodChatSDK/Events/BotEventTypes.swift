//
//  BotEventTypes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation

public enum BotEventTypes {
    case CREATE_BOT(Bot)
    case BOT_MESSAGE(String?)
    case CREATE_BOT_COMMAND(BotInfo)
    case REMOVE_BOT_COMMAND(BotInfo)
    case START_BOT(String)
    case STOP_BOT(String)
}
