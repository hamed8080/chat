//
//  GetUserInfoResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class UserInfoModel: ResponseModel, ResponseModelDelegates {
    
    public let user:    User
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.user   = User(messageContent: messageContent)
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(userObject:     User,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.user   = userObject
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["user": user.formatToJSON()]
        
        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]
        
        return resultAsJSON
    }
    
}


@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class GetUserInfoResponse: UserInfoModel {
    
}


