//
//  MapRoutingModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/12/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class MapRoutingModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError      Bool
     *  - errorMessage  String?
     *  - errorCode     Int?
     *  - result        JSON
     ---------------------------------------
     * responseAsModel:
     *  - hasError      Bool
     *  - errorMessage  String?
     *  - errorCode     Int?
     *  - result        MapSearch
     ---------------------------------------
     */
    
    // MapReverseModel model properties
    public let hasError:           Bool
    public let errorMessage:       String?
    public let errorCode:          Int?
    public var result:             MapRouting
    
    public var resultJSON: JSON = [:]
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.result             = MapRouting(messageContent: messageContent)
        self.resultJSON         = result.formatToJSON()
    }
    
    public init(routsObject:    MapRouting,
                hasError:       Bool,
                errorMessage:   String?,
                errorCode:      Int?) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.result           = routsObject
        self.resultJSON       = result.formatToJSON()
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let finalResult: JSON = ["result":          resultJSON,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage ?? NSNull(),
                                 "errorCode":       errorCode ?? NSNull()]
        
        return finalResult
    }
    
}



