//
//  DeliverRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class DeliverRequestHandler {
	
	class func handle( _ req:MessageDeliverRequest, _ chat:Chat){
		chat.prepareToSendAsync(req: req.messageId,
								clientSpecificUniqueId: req.uniqueId,
								typeCode: req.typeCode ,
                                plainText:true,
                                messageType: .DELIVERY,
								uniqueIdResult: nil,
								completion: nil )
	}
}
