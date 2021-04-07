//
//  NewLeaveThreadRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public class NewLeaveThreadRequest: BaseRequest {
	
    public let threadId     : Int
    public let clearHistory : Bool?
	
	public init(threadId:Int, clearHistory:Bool? = false, typeCode: String? = nil, uniqueId: String? = nil) {
		self.clearHistory = clearHistory
		self.threadId     = threadId
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
	private enum CodingKeys : String , CodingKey {
		case clearHistory = "clearHistory"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(clearHistory, forKey: .clearHistory)
	}
}
