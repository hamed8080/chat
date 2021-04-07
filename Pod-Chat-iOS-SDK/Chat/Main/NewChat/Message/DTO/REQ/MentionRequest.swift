//
//  MentionRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/27/21.
//

import Foundation

public class MentionRequest : BaseRequest {
	
	public var count:               Int = 50
	public var offset:              Int = 0
	public let threadId:            Int
	public let onlyUnreadMention:   Bool

	public init (threadId:Int,
				 onlyUnreadMention:Bool,
				 count:Int = 50 ,
				 offset:Int = 0,
                 uniqueId: String? = nil,
                 typeCode: String? = nil){
		self.count = count
		self.offset = offset
		self.threadId = threadId
		self.onlyUnreadMention = onlyUnreadMention
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
	private enum CodingKeys : String , CodingKey{
        case count           = "count"
        case offset          = "offset"
		case unreadMentioned = "unreadMentioned"
        case allMentioned    = "allMentioned"
	}
	
	public override func encode(to encoder: Encoder)throws{
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(count, forKey: .count)
		try container.encode(offset, forKey: .offset)
		if onlyUnreadMention {
			try container.encode(true, forKey: .unreadMentioned)
		} else {
			try container.encode(true, forKey: .allMentioned)
		}
	}
	
}
