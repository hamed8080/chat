//
//  NewJoinPublicThreadRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public class NewJoinPublicThreadRequest: BaseRequest {
	
	public var threadName:String
	
	public init(threadName:String,uniqueId: String? = nil, typeCode: String? = nil){
		self.threadName = threadName
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
}
