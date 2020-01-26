//
//  NotSeenDurationModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/30/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON


open class NotSeenDurationModel {
    
    public let hasError:        Bool
    public let errorMessage:    String
    public let errorCode:       Int
    public let notSeenDuration: [UserLastSeenDuration]
    
    public init(notSeenDuration:    [UserLastSeenDuration],
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.notSeenDuration  = notSeenDuration
    }
    
    public init(notSeenDuration:    JSON,
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        var users = [UserLastSeenDuration]()
        for item in notSeenDuration {
            users.append(UserLastSeenDuration(userId: Int(item.0)!, time: item.1.intValue))
        }
        self.notSeenDuration  = users
    }

    public func returnDataAsJSON() -> JSON {
        
        var result: JSON = []
        for item in notSeenDuration {
            result.appendIfArray(json: item.convertDataToJSON())
        }
        
        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]

        return resultAsJSON
    }
    
}


open class UserLastSeenDuration {
    
    public var userId: Int
    public var time:   Int
    
    init(userId: Int, time: Int) {
        self.userId = userId
        self.time   = time
    }
    
    public func convertDataToJSON() -> JSON {
        var result: JSON = [:]
        result["userId"]    = JSON(userId)
        result["time"]      = JSON(time)
        return result
    }
    
}

