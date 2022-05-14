//
//  RemoveParticipantsRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public class RemoveParticipantsRequest : BaseRequest {
	
	public let participantIds:  [Int]
	public let threadId:        Int
	
	public init(participantId:Int , threadId:Int ,uniqueId: String? = nil, typeCode: String? = nil) {
        self.threadId       = threadId
		self.participantIds = [participantId]
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
	
	public init(participantIds:[Int] , threadId:Int ,uniqueId: String? = nil, typeCode: String? = nil) {
        self.threadId       = threadId
		self.participantIds = participantIds
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
}
