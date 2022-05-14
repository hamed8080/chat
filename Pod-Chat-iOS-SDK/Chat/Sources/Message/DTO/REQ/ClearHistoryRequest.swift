//
//  ClearHistoryRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public class ClearHistoryRequest: BaseRequest {
	
	public let threadId:    Int
	
	public init(threadId: Int, typeCode: String? = nil, uniqueId: String? = nil) {
		self.threadId   = threadId
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
}
