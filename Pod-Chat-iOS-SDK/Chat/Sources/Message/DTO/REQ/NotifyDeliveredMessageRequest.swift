//
//  NotifyDeliveredMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/27/21.
//

import Foundation
public struct NotifyDeliveredMessageRequest : Encodable {
	
	public let messageId:   Int
	public let ownerId:     Int
	
	public init(messageId:  Int, ownerId:  Int) {
		self.messageId  = messageId
		self.ownerId    = ownerId
	}
}
