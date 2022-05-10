//
//  MessageSeenRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public class MessageSeenRequest: BaseRequest {
	
	let messageId :String
	
	public init(messageId:Int, typeCode: String? = nil, uniqueId: String? = nil) {
		self.messageId = "\(messageId)"
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
}
