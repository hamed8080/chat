//
//  GetMessageSeenList.swift
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
    
    public class GetMessageSeenList: CallbackProtocol {
        var sendParams: SendChatMessageVO
        init(parameters: SendChatMessageVO) {
            self.sendParams = parameters
        }
        func onResultCallback(uID: String, response: JSON, success: @escaping callbackTypeAlias, failure: @escaping callbackTypeAlias) {
            
            let hasError = response["hasError"].boolValue
            let errorMessage = response["errorMessage"].stringValue
            let errorCode = response["errorCode"].intValue
            
            if (!hasError) {
//                let content = sendParams["content"]
                let content = sendParams.content.convertToJSON()
                let count = content["count"].intValue
                let offset = content["offset"].intValue
                
                let messageContent: [JSON] = response["result"].arrayValue
                let contentCount = response["contentCount"].intValue
                
                let getBlockedModel = GetThreadParticipantsModel(messageContent: messageContent, contentCount: contentCount, count: count, offset: offset, hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
                
                success(getBlockedModel)
            }
            
        }
        
    }
    
}
