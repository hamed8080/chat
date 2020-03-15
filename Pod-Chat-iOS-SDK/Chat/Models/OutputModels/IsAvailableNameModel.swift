//
//  IsAvailableNameModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class IsAvailableNameModel {
    
    // user model properties
    public let hasError:        Bool
    public let errorMessage:    String
    public let errorCode:       Int
    
    public let uniqueName:      String?
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.uniqueName     = messageContent["uniqueName"].string
    }
    
    public init(uniqueName:     String?,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.uniqueName     = uniqueName
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["uniqueName":   uniqueName ?? NSNull()]
        
        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]
        
        return resultAsJSON
    }
    
}
