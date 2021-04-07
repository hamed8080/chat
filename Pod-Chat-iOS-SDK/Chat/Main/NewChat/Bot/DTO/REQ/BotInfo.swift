//
//  BotInfo.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
public class BotInfo : Decodable{
	public var name:     String?
	public var botUserId:   Int?
	public var commandList: [String]
}
