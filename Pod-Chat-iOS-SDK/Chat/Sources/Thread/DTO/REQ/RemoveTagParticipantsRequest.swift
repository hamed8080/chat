//
//  RemoveThreadFromTagRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
public class RemoveTagParticipantsRequest: BaseRequest {
	
    public var tagId             : Int
    public var tagParticipants   : [TagParticipant]
	
    public init(tagId:Int,tagParticipants:[TagParticipant], uniqueId: String? = nil){
        self.tagId           = tagId
        self.tagParticipants = tagParticipants
        super.init(uniqueId: uniqueId)
	}
}
