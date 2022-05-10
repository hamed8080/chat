//
//  MessageDeliveredUsersRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/27/21.
//

import Foundation
public class MessageDeliveredUsersRequest : BaseRequest{
	
	let messageId:Int
	let offset:Int
	let count:Int
	
	public init (messageId:Int,count:Int = 50 , offset:Int = 0,uniqueId: String? = nil, typeCode: String? = nil){
		self.messageId = messageId
        self.offset    = offset
        self.count     = count
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
	private enum CodingKeys:String , CodingKey{
		case messageId = "messageId"
        case offset    = "offset"
        case count     = "count"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try? container.encode(messageId, forKey: .messageId)
		try? container.encode(offset, forKey: .offset)
		try? container.encode(count, forKey: .count)
	}
	
}
