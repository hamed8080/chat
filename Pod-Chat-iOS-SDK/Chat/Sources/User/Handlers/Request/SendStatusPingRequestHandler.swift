//
//  SendStatusPingRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class SendStatusPingRequestHandler {
	
	class func handle(_ req:SendStatusPingRequest,_ chat:Chat ){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								messageType: .STATUS_PING)
	}
}
