//
//  CustomerInfoRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class CustomerInfoRequestHandler {
	
	class func handle(_ req:CustomerInfoRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<CustomerInfo>,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
        chat.prepareToSendAsync(req: req.coreUserIds,
								clientSpecificUniqueId: req.uniqueId,
								messageType: .CUSTOMER_INFO,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? CustomerInfo, response.uniqueId, response.error)
        }
	}
}
