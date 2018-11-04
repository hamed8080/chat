//
//  GetBlockedListModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/13/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class GetBlockedListModel {
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
    let hasError:           Bool
    let errorMessage:       String
    let errorCode:          Int
    
    // result model
    var contentCount:       Int = 0
    var hasNext:            Bool = false
    var nextOffset:         Int = 0
    var blockedList:        [BlockedUser] = []
    
    var blockedListJSON:    [JSON] = []
    
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
            let blockedUser = BlockedUser(messageContent: item)
            let blockedUserJSON = blockedUser.formatToJSON()
            
            blockedList.append(blockedUser)
            blockedListJSON.append(blockedUserJSON)
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
