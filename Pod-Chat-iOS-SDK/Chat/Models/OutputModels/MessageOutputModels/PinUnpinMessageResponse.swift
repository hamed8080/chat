//
//  PinUnpinMessageResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/29/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON


open class PinUnpinMessageResponse: ResponseModel, ResponseModelDelegates {
    
    public let pinUnpinModel:   PinUnpinMessage
    
    public init(pinUnpinModel:  PinUnpinMessage,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.pinUnpinModel = pinUnpinModel
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }

    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["pinMessageVO": pinUnpinModel.formatToJSON()]

        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]

        return resultAsJSON
    }

}


open class PinUnpinMessageModel: PinUnpinMessageResponse {
    
}


