//
//  PinUnpinMessageModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/29/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON


open class PinUnpinMessageModel {
    
    public let hasError:        Bool
    public let errorMessage:    String
    public let errorCode:       Int
    public let pinUnpinModel:   PinUnpinMessage
    
    public init(pinUnpinModel:  PinUnpinMessage,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.pinUnpinModel  = pinUnpinModel
        
    }

    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["pinMessageVO": pinUnpinModel.convertContentToJSON()]

        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]

        return resultAsJSON
    }

}

