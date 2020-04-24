//
//  CreateBotResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/5/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class CreateBotResponse: ResponseModel, ResponseModelDelegates {
    
    public let bot: BotVO

    public init(bot:            BotVO,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {

        self.bot  = bot
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }

    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.bot  = BotVO(messageContent: messageContent)
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }

    public func returnDataAsJSON() -> JSON {
        let botInfoJSON: JSON = ["botVO":   bot.formatToJSON()]
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



