//
//  UnBlockRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/1/21.
//

import Foundation

public class UnBlockRequest: BaseRequest {
	
	public let contactId:   Int?
	public let threadId:    Int?
	public let userId:      Int?
	
	
	public init(contactId: Int? = nil,
				threadId:   Int? = nil,
				userId:     Int? = nil,
                uniqueId: String? = nil) {
		self.contactId  = contactId
		self.threadId   = threadId
		self.userId     = userId
        super.init(uniqueId: uniqueId)
	}
	
	private enum CodingKeys : String ,CodingKey{
		case contactId = "contactId"
        case threadId  = "threadId"
        case userId    = "userId"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try? container.encodeIfPresent(contactId, forKey: .contactId)
		try? container.encodeIfPresent(threadId, forKey: .threadId)
		try? container.encodeIfPresent(userId, forKey: .userId)
	}
}
