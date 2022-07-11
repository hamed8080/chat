//
//  StartStopBotRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public class StartStopBotRequest: BaseRequest {
	
	public let botName:     String
	public let threadId:    Int
	
	public init(botName: String, threadId:Int, uniqueId: String? = nil) {
		self.botName = botName
		self.threadId = threadId
        super.init(uniqueId: uniqueId)
	}
	
	private enum CodingKeys : String , CodingKey{
		case botName  = "botName"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(botName, forKey: .botName)
	}
}
