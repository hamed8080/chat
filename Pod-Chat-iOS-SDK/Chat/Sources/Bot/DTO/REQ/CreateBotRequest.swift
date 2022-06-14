//
//  CreateBotRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public class CreateBotRequest: BaseRequest {
	
	public var botName:String
	
	public init(botName:String, uniqueId: String? = nil){
		self.botName = botName
        super.init(uniqueId: uniqueId)
	}
}
