//
//  UserInfoModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UserInfoModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError     Bool
     *  - errorMessage String
     *  - errorCode    Int
     *  + result       JSON or UserInfoModel:
     *      + user          UserAsJSON
     *          - cellphoneNumber:    String?
     *          - email:              String?
     *          - id:                 Int?
     *          - image:              String?
     *          - lastSeen:           Int?
     *          - name:               String?
     *          - receiveEnable:      Bool?
     *          - sendEnable:         Bool?
     ---------------------------------------
     * responseAsModel:
     *  - hasError     Bool
     *  - errorMessage String
     *  - errorCode    Int
     *  + user         User
     ---------------------------------------
     */
    
    // user model properties
    let hasError:           Bool
    let errorMessage:       String
    let errorCode:          Int
    let user:               User
    
    var userJSON: JSON = []
    
    init(messageContent: JSON, hasError: Bool, errorMessage: String, errorCode: Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.user = User(messageContent: messageContent)
        self.userJSON = user.formatToJSON()
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["user": userJSON]
        
        let resultAsJSON: JSON = ["result": result,
                                  "hasError": hasError,
                                  "errorMessage": errorMessage,
                                  "errorCode": errorCode]
        
        return resultAsJSON
    }
    
}
