//
//  BlockedContactModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/13/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class BlockedContactModel {
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
    
    public let hasError:           Bool
    public let errorMessage:       String
    public let errorCode:          Int
    public let blockedContact:     BlockedContact
    
    public var blockedContactJSON: JSON = [:]
    
    init(messageContent: JSON, hasError: Bool, errorMessage: String, errorCode: Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.blockedContact = BlockedContact(messageContent: messageContent)
        self.blockedContactJSON = blockedContact.formatToJSON()
        
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["blockedContact": blockedContactJSON]
        
        let resultAsJSON: JSON = ["result": result,
                                  "hasError": hasError,
                                  "errorMessage": errorMessage,
                                  "errorCode": errorCode]
        
        return resultAsJSON
    }
    
}
