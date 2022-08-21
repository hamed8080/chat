//
//  ThreadParticipantsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/24/21.
//

import Foundation
public class ThreadParticipantsRequest : BaseRequest {
	
	public let count            :Int
	public let offset           :Int
	public let threadId         :Int
    public var admin            :Bool = false
	
	public init (threadId:Int,offset:Int = 0, count:Int = 50 ,uniqueId:String? = nil){
        self.count    = count
        self.offset   = offset
		self.threadId = threadId
        super.init(uniqueId: uniqueId)
	}
	
	private enum CodingKeys:String ,CodingKey{
        case count       = "count"
        case offset      = "offset"
        case admin       = "admin"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try? container.encodeIfPresent(count, forKey: .count)
		try? container.encodeIfPresent(offset, forKey: .offset)
        try? container.encodeIfPresent(admin, forKey: .admin)//for get thread admins only
	}
}
