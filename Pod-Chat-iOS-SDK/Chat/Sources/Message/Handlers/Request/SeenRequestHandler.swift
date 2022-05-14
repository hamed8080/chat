//
//  SeenRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class SeenRequestHandler {
	
    class func handle( _ req:MessageSeenRequest, _ chat:Chat , _ uniqueIdResult:UniqueIdResultType = nil){
		chat.prepareToSendAsync(req: req.messageId,
								clientSpecificUniqueId: req.uniqueId,
								typeCode: req.typeCode ,
                                plainText:true,
								messageType: .SEEN,
                                uniqueIdResult: uniqueIdResult
        )
	}
}
