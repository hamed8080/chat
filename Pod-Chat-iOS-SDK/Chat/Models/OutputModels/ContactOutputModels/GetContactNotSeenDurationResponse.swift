//
//  GetContactNotSeenDurationResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/30/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class NotSeenDurationModel: ResponseModel, ResponseModelDelegates {
    
    public let notSeenDuration: [UserLastSeenDuration]
    
    public init(notSeenDuration:    [UserLastSeenDuration],
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        self.notSeenDuration  = notSeenDuration
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(notSeenDuration:    JSON,
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        var users = [UserLastSeenDuration]()
        for item in notSeenDuration {
            users.append(UserLastSeenDuration(userId: Int(item.0)!, time: item.1.intValue))
        }
        self.notSeenDuration  = users
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
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


@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class GetContactNotSeenDurationResponse: NotSeenDurationModel {
    
}

