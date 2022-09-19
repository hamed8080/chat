//
//  BotInfo.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation

/// Bot more information.
public class BotInfo : Decodable{

    /// The name of the bot.
	public var name:     String?

    /// The bot userId.
	public var botUserId:   Int?

    /// List of commands.
	public var commandList: [String]?
}
