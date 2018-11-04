//
//  BlockedUserModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/13/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class BlockedUserModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError     Bool
     *  - errorMessage String
     *  - errorCode    Int
     *  + result       JSON or UserInfoModel:
     *      + user          UserAsJSON
     *          - firstName:    String?
     *          - nickeName:    String?
     *          - lastName:     String?
     *          - id:           Int?
     ---------------------------------------
     * responseAsModel:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  + blockedUser   BlockedUserUser
     ---------------------------------------
     */
    
    let hasError:           Bool
    let errorMessage:       String
    let errorCode:          Int
    let blockedUser:        BlockedUser
    
    var blockedUserJSON:    JSON = [:]
    
    init(messageContent: JSON, hasError: Bool, errorMessage: String, errorCode: Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.blockedUser = BlockedUser(messageContent: messageContent)
        self.blockedUserJSON = blockedUser.formatToJSON()
        
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["blockedUser": blockedUserJSON]
        
        let resultAsJSON: JSON = ["result": result,
                                  "hasError": hasError,
                                  "errorMessage": errorMessage,
                                  "errorCode": errorCode]
        
        return resultAsJSON
    }
    
}
