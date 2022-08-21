//
//  ‌BatchRemoveContactRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation

class BatchRemoveContactRequestHandler{
    
    class func handle(_ req:RemoveContactsRequest,
                      _ chat:Chat,
                      _ completion: @escaping CompletionType<Bool>,
                      _ uniqueIdResult:UniqueIdResultType = nil){
        chat.prepareToSendAsync(req: req.contactIds,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .REMOVE_CONTACTS,
                                uniqueIdResult: uniqueIdResult) { response in
            let removeResponse = response.result as? RemoveContactResponse
            removeFromCacheIfExist(chat: chat, removeContactResponse: removeResponse, contactIds: req.contactIds)
            completion(removeResponse?.deteled ?? false , response.uniqueId , response.error)
        }
    }
    
    private class func removeFromCacheIfExist(chat:Chat , removeContactResponse:RemoveContactResponse? , contactIds:[Int]){
        if removeContactResponse?.deteled == true{
            CacheFactory.write(cacheType: .DELETE_CONTACTS(contactIds))
			PSM.shared.save()
        }
    }
}
