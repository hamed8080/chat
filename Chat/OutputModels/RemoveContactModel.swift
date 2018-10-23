//
//  RemoveContactModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class RemoveContactModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  - result        Bool
     ---------------------------------------
     * responseAsModel:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  - result        Bool
     ---------------------------------------
     */
    
    // RemoveContactcs model properties
    let hasError:           Bool
    let errorMessage:       String?
    let errorCode:          Int?
    var result:             Bool
    
    init(messageContent: JSON) {
        self.hasError           = messageContent["hasError"].boolValue
        self.errorMessage       = messageContent["message"].string
        self.errorCode          = messageContent["errorCode"].int
        self.result             = messageContent["result"].boolValue
    }
    
    public func returnDataAsJSON() -> JSON {
        let finalResult: JSON = ["result": result,
                                 "hasError": hasError,
                                 "errorMessage": errorMessage ?? NSNull(),
                                 "errorCode": errorCode ?? NSNull()]
        
        return finalResult
    }
}
