//
//  NewAddBotCommandRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public class NewAddBotCommandRequest: BaseRequest {
	
	public let botName			: String
	public var commandList		: [String] = []
	
	public init(botName: String, commandList: [String],typeCode: String? = nil, uniqueId: String? = nil) {
		
		self.botName    = botName
		for command in commandList {
			if (command.first == "/") {
				self.commandList.append(command)
			} else {
				self.commandList.append("/\(command)")
			}
		}
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
	private enum CodingKeys : String , CodingKey{
        case botName     = "botName"
		case commandList = "commandList"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(commandList, forKey: .commandList)
		try container.encode(botName, forKey: .botName)
	}
}
