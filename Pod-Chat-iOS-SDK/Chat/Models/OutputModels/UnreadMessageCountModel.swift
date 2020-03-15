//
//  UnreadMessageCountModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UnreadMessageCountModel {
    
    // user model properties
    public let hasError:        Bool
    public let errorMessage:    String
    public let errorCode:       Int
    
    public let unreadCount:     Int
    
    public init(unreadCount:    Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.unreadCount    = unreadCount
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["unreadCount":  unreadCount]
        
        let resultAsJSON: JSON = ["result":     result,
                                  "hasError":   hasError,
                                  "errorMessage": errorMessage,
                                  "errorCode":  errorCode]
        
        return resultAsJSON
    }
    
}
