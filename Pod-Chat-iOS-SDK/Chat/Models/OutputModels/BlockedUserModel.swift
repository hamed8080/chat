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
    
    public let hasError:           Bool
    public let errorMessage:       String
    public let errorCode:          Int
    public let blockedContact:     BlockedUser
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.blockedContact = BlockedUser(messageContent: messageContent)
    }
    
    public init(theBlockedContact:  BlockedUser,
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        self.blockedContact     = theBlockedContact
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["blockedContact":   blockedContact.formatToJSON()]
        let resultAsJSON: JSON = ["result":     result,
                                  "hasError":   hasError,
                                  "errorMessage": errorMessage,
                                  "errorCode":  errorCode]
        
        return resultAsJSON
    }
    
}
