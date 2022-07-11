//
//  NotSeenDurationRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/1/21.
//

import Foundation
public class NotSeenDurationRequest: BaseRequest {
	
	public let userIds     : [Int]

	public init(userIds: [Int],uniqueId: String? = nil) {
		self.userIds    = userIds
        super.init(uniqueId: uniqueId)
	}

	private enum CodingKeys: String ,CodingKey{
		case userIds = "userIds"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try? container.encode(userIds, forKey: .userIds)
	}
}
