//
//  MapRoutingResponse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/12/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class MapRoutingModel: ResponseModel, ResponseModelDelegates {
    
    public var result:  MapRouting
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.result = MapRouting(messageContent: messageContent)
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(routsObject:    MapRouting,
                hasError:       Bool,
                errorMessage:   String?,
                errorCode:      Int?) {
        
        self.result = routsObject
        super.init(hasError:        hasError,
                   errorMessage:    errorMessage ?? "",
                   errorCode:       errorCode ?? 0)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let finalResult: JSON = ["result":          result.formatToJSON(),
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode]
        
        return finalResult
    }
    
}

@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class MapRoutingResponses: MapRoutingModel {
    
}

