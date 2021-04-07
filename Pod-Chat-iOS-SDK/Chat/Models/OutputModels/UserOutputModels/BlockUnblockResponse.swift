//
//  BlockUnblockResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/13/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class BlockedUserModel: ResponseModel, ResponseModelDelegates {
    
    public var blockedContact:     BlockedUser
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.blockedContact = BlockedUser(messageContent: messageContent)
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(theBlockedContact:  BlockedUser,
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        self.blockedContact     = theBlockedContact
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
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

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class BlockUnblockResponse: BlockedUserModel {
    
}
