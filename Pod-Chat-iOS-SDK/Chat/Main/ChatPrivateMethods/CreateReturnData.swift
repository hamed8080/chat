//
//  CreateReturnData.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


class CreateReturnData {
    
    let hasError:       Bool
    let errorMessage:   String
    let errorCode:      Int
    let contentCount:   Int
    let result:         JSON?
    let resultAsString: String?
    let resultAsArray:  [JSON]?
    let subjectId:      Int?
    
    init(hasError:      Bool,
         errorMessage:  String?,
         errorCode:     Int?,
         result:        JSON?,
         resultAsArray: [JSON]?,
         resultAsString: String?,
         contentCount:  Int?,
         subjectId:     Int?) {
        
        self.hasError       = hasError
        self.errorMessage   = errorMessage ?? ""
        self.errorCode      = errorCode ?? 0
        self.contentCount   = contentCount ?? 0
        self.result         = result
        self.resultAsArray  = resultAsArray
        self.resultAsString = resultAsString
        self.subjectId      = subjectId
    }
    
    
    func returnJSON() -> JSON {
        
        var obj: JSON = ["hasError":    hasError,
                         "errorMessage": errorMessage,
                         "errorCode":   errorCode,
                         "result":      NSNull(),
                         "contentCount": contentCount,
                         "subjectId":   subjectId ?? NSNull()]
        
        if let myResult = result {
            obj["result"] = myResult
        } else if let myResult = resultAsArray {
            obj["result"] = JSON(myResult)
        } else if let myResult = resultAsString {
            obj["result"] = JSON(myResult)
        }
        
        return obj
    }
    
}
