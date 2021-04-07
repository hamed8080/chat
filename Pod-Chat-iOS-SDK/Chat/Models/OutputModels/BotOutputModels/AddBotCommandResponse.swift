//
//  AddBotCommandResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/5/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class AddBotCommandResponse: ResponseModel, ResponseModelDelegates  {
    
    public let botInfo: BotInfoVO
    
    public init(botInfo:        BotInfoVO,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.botInfo    = botInfo
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.botInfo  = BotInfoVO(messageContent: messageContent)
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }

    public func returnDataAsJSON() -> JSON {
        let botInfoJSON: JSON = ["botInfoVO":   botInfo.formatToJSON()]
        
        let resultAsJSON: JSON = ["result":         botInfoJSON,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]
        return resultAsJSON
    }
    
    public func returnDataAsJSONArray() -> [JSON] {
        return []
    }
    
}

