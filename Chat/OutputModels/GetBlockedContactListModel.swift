//
//  GetBlockedListModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/13/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class GetBlockedContactListModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError     Bool
     *  - errorMessage String
     *  - errorCode    Int
     *  + result       JSON or BlockedListModel:
     *      - contentCount      Int
     *      - hasNext           Bool
     *      - nextOffset        Int
     *      + blockedUsers      BlockedListAsJSON
     *          - firstName:        String?
     *          - nickeName:        String?
     *          - lastName:         String?
     *          - id:               Int?
     ---------------------------------------
     * responseAsModel:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  + blockedUser   [BlockedUser]
     ---------------------------------------
     */
    
    // GetBlockedList model properties
    public let hasError:           Bool
    public let errorMessage:       String
    public let errorCode:          Int
    
    // result model
    public var contentCount:       Int = 0
    public var hasNext:            Bool = false
    public var nextOffset:         Int = 0
    public var blockedList:        [BlockedContact] = []
    
    public var blockedListJSON:    [JSON] = []
    
    init(messageContent: [JSON], contentCount: Int, count: Int, offset: Int, hasError: Bool, errorMessage: String, errorCode: Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        let messageLength = messageContent.count
        self.contentCount = contentCount
        self.hasNext = false
        let x: Int = count + offset
        if (x < contentCount) && (messageLength > 0) {
            self.hasNext = true
        }
        self.nextOffset = offset + messageLength
        
        for item in messageContent {
            let blockedContact = BlockedContact(messageContent: item)
            let blockedContactJSON = blockedContact.formatToJSON()
            
            blockedList.append(blockedContact)
            blockedListJSON.append(blockedContactJSON)
        }
        
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["contentCount": contentCount,
                            "hasNext":      hasNext,
                            "nextOffset":   nextOffset,
                            "blockedUsers": blockedListJSON]
        
        let resultAsJSON: JSON = ["result": result,
                                  "hasError": hasError,
                                  "errorMessage": errorMessage,
                                  "errorCode": errorCode]
        
        return resultAsJSON
    }
    
}
