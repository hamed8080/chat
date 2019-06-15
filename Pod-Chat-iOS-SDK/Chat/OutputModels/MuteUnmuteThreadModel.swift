//
//  MuteUnmuteThreadModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class MuteUnmuteThreadModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError     Bool
     *  - errorMessage String
     *  - errorCode    Int
     *  + result       JSON or MuteUnmuteThreadModel:
     *      + threadId:     Int
     ---------------------------------------
     * responseAsModel:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  + threadId      Int
     ---------------------------------------
     */

    public let hasError:        Bool
    public let errorMessage:    String
    public let errorCode:       Int
    public let threadId:        Int
    
    public init(threadId:       Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.threadId       = threadId
        
    }

    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["threadId": threadId]

        let resultAsJSON: JSON = ["result": result,
                                  "hasError": hasError,
                                  "errorMessage": errorMessage,
                                  "errorCode": errorCode]

        return resultAsJSON
    }

}
