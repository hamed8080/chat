//
//  MapSearchModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 10/11/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class MapSearchModel {
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
    public var result:             MapSearch
    
    public var resultJSON: JSON = [:]
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.result             = MapSearch(messageContent: messageContent)
        self.resultJSON         = result.formatToJSON()
    }
    
    public init(hasError:       Bool,
                errorMessage:   String?,
                errorCode:      Int?,
                searchObject:   MapSearch) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.result           = searchObject
        self.resultJSON       = result.formatToJSON()
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let theResult: JSON = ["reverse": resultJSON]
        let finalResult: JSON = ["result":          theResult,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage ?? NSNull(),
                                 "errorCode":       errorCode ?? NSNull()]
        
        return finalResult
    }
    
}


