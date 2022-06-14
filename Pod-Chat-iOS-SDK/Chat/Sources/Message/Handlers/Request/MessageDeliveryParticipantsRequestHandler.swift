//
//  MessageDeliveryParticipantsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class MessageDeliveryParticipantsRequestHandler {
	
	class func handle( _ req:MessageDeliveredUsersRequest,
					   _ chat:Chat,
					   _ completion: @escaping PaginationCompletionType<[Participant]> ,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								messageType: .GET_MESSAGE_DELEVERY_PARTICIPANTS,
                                uniqueIdResult: uniqueIdResult){ response in
            let pagination = Pagination(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [Participant] , response.uniqueId, pagination , response.error)
        }
	}
}
