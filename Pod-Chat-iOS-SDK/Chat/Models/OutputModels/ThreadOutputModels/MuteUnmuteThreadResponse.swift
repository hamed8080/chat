//
//  MuteUnmuteThreadResponse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class MuteUnmuteThreadModel: ResponseModel, ResponseModelDelegates {
    
    public let threadId:    Int
    
    public init(threadId:       Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.threadId   = threadId
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }

    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["threadId":     threadId]

        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]

        return resultAsJSON
    }

}

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class MuteUnmuteThreadResponse: MuteUnmuteThreadModel {
    
}


