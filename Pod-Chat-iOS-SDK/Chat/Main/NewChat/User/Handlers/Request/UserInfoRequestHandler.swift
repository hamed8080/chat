//
//  UserInfoRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class UserInfoRequestHandler {
	
	class func handle(_ req:UserInfoRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<User>,
                       _ cacheResponse: CacheResponseType<User>? = nil,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: nil,
								clientSpecificUniqueId: req.uniqueId,
								typeCode: req.typeCode ,
								messageType: .USER_INFO,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? User , response.uniqueId , response.error)
        }
        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .USER_INFO){ response in
            cacheResponse?(response.cacheResponse as? User , response.uniqueId, nil)
        }
	}
    
    
    class func getUserForChatReady(){
        var count    = 0
        let maxRetry = 5
        if Chat.sharedInstance.userInfo == nil{
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                UserInfoRequestHandler.handle(.init(), Chat.sharedInstance){ user, uniqueId, error in
                    if let user = user {
                        Chat.sharedInstance.delegate?.chatState(state: .CHAT_READY, currentUser: user, error: nil)
                        Chat.sharedInstance.setUser(user: user)
                        timer.invalidate()
                    }else if count < maxRetry{
                        count += 1
                    }else{
                        //reach to max retry
                        timer.invalidate()
                        Chat.sharedInstance.delegate?.chatError(error: .init(code: .ERROR_RAEAY_CHAT,message: error?.message))
                    }
                }
            }
        }else {
            // it mean chat was connected before and reconnected again
            Chat.sharedInstance.delegate?.chatState(state: .CHAT_READY, currentUser: Chat.sharedInstance.userInfo, error: nil)
            Chat.sharedInstance.asyncManager.sendPingTimer()
        }
    }
}
