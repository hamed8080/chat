//
//  ArchiveThreadRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public class ArchiveThreadRequest: BaseRequest {
	
    public let threadId     : Int
    
	public init(threadId:Int, uniqueId: String? = nil) {
		self.threadId     = threadId
        super.init(uniqueId: uniqueId)
	}
}

