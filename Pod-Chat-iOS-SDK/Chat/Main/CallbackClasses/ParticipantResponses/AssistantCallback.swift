//
//  AssistantCallback.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/9/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftyBeaver
import FanapPodAsyncSDK


public class AssistantCallback: CallbackProtocol {
    
    func onResultCallback(uID:      String,
                          response: CreateReturnData,
                          success:  @escaping callbackTypeAlias,
                          failure:  @escaping callbackTypeAlias) {
        log.verbose("AssistantCallback", context: "Chat")
        
        if let content = response.resultAsArray as? [JSON] {
            let addParticipantModel = AssistantResponse(messageContent: content,
                                                        hasError:       response.hasError,
                                                        errorMessage:   response.errorMessage,
                                                        errorCode:      response.errorCode)
            success(addParticipantModel)
        }
    }
}
