//
//  MapReverseResponse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/11/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class MapReverseModel: ResponseModel, ResponseModelDelegates {
    
    public var result: MapReverse
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.result = MapReverse(messageContent: messageContent)
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(hasError:       Bool,
                errorMessage:   String?,
                errorCode:      Int?,
                reversObject:   MapReverse) {
        
        self.result = reversObject
        super.init(hasError:        hasError,
                   errorMessage:    errorMessage ?? "",
                   errorCode:       errorCode ?? 0)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let theResult: JSON = ["reverse":   result.formatToJSON()]
        let finalResult: JSON = ["result":          theResult,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode]
        
        return finalResult
    }
    
}


open class MapReverseResponse: MapReverseModel {
    
}


