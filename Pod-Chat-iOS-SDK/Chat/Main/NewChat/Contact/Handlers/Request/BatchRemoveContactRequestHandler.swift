//
//  ‌BatchRemoveContactRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation
import Alamofire

class BatchRemoveContactRequestHandler{
    
    class func handle(_ req:NewRemoveContactsRequest,
                      _ chat:Chat,
                      _ completion: @escaping CompletionType<Bool>,
                      _ uniqueIdResult:UniqueIdResultType = nil){
        chat.prepareToSendAsync(req: req.contactIds,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                messageType: .REMOVE_CONTACTS,
                                uniqueIdResult: uniqueIdResult) { response in
            let removeResponse = response.result as? NewRemoveContactResponse
            removeFromCacheIfExist(chat: chat, removeContactResponse: removeResponse, contactIds: req.contactIds)
            completion(removeResponse?.deteled ?? false , response.uniqueId , response.error)
        }
    }
    
    private class func removeFromCacheIfExist(chat:Chat , removeContactResponse:NewRemoveContactResponse? , contactIds:[Int]){
        if removeContactResponse?.deteled == true{
            CacheFactory.write(cacheType: .DELETE_CONTACTS(contactIds))
			PSM.shared.save()
        }
    }
}
