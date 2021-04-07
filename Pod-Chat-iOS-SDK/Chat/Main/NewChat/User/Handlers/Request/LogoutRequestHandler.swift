//
//  LogoutRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/4/21.
//

import Foundation
class LogoutRequestHandler{
    
    class func handle(_ chat:Chat){
        chat.prepareToSendAsync(req: nil,
                                clientSpecificUniqueId: UUID().uuidString,
                                typeCode: nil ,
                                messageType: .LOGOUT)
        CacheFactory.write(cacheType: .DELETE_ALL_CACHE_DATA)
        CacheFactory.save()
        chat.stopAllChatTimers()
        chat.asyncClient?.disposeAsyncObject()
    }
}
