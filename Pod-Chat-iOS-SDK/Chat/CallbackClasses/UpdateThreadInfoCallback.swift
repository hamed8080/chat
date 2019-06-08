//
//  UpdateThreadInfoCallback.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK


extension Chat {
    
    func chatDelegateUpdateThreadInfo(threadInfo: JSON) {
        delegate?.threadEvents(type: ThreadEventTypes.UpdateThreadInfo, result: threadInfo)
    }
    public class UpdateThreadInfoCallback: CallbackProtocol {
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            log.verbose("UpdateThreadInfoCallback", context: "Chat")
            success(response)
        }
        
    }
    
}
