//
//  Bot.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
public class Bot : Codable {
	public var apiToken  : String?
	public var thing     : Thing?
	
	private enum CodingKeys : String , CodingKey{
		case apiToken = "apiToken"
        case thing    = "thingVO"
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(apiToken, forKey: .apiToken)
		try container.encodeIfPresent(thing, forKey: .thing)
	}
}


public class Thing : Codable{
    
	public var id:                  Int?    // its thing id of relevant thing of this bot in SSO
	public var name:                String? // bot name
	public var title:               String? // bot name
	public var type:                String? // it must be Bot
	public var bot:                 Bool?
	public var active:              Bool?
	public var chatSendEnable:      Bool?
	public var chatReceiveEnable:   Bool?
	public var owner:               Participant?
	public var creator:             Participant?
}
