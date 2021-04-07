//
//  GetBlockedListResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/13/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class GetBlockedUserListModel: ResponseModel, ResponseModelDelegates {
    
    public var contentCount:       Int = 0
    public var hasNext:            Bool = false
    public var nextOffset:         Int = 0
    public var blockedList:        [BlockedUser] = []
    
    public init(messageContent: [JSON],
                contentCount:   Int,
                count:          Int,
                offset:         Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        let messageLength = messageContent.count
        self.contentCount = contentCount
        self.hasNext = false
        let x: Int = count + offset
        if (x < contentCount) && (messageLength > 0) {
            self.hasNext = true
        }
        self.nextOffset = offset + messageLength
        
        for item in messageContent {
            let blockedContact = BlockedUser(messageContent: item)
            blockedList.append(blockedContact)
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(messageContent: [BlockedUser]?,
                contentCount:   Int,
                count:          Int,
                offset:         Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        if let blockedList = messageContent {
            
            let messageLength = blockedList.count
            self.contentCount = contentCount
            self.hasNext = false
            let x: Int = count + offset
            if (x < contentCount) && (messageLength > 0) {
                self.hasNext = true
            }
            self.nextOffset = offset + messageLength
            
            for item in blockedList {
                self.blockedList.append(item)
            }
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        var blockedUserArr = [JSON]()
        for item in blockedList {
            blockedUserArr.append(item.formatToJSON())
        }
        let result: JSON = ["contentCount": contentCount,
                            "hasNext":      hasNext,
                            "nextOffset":   nextOffset,
                            "blockedUsers": blockedUserArr]
        
        let resultAsJSON: JSON = ["result": result,
                                  "hasError": hasError,
                                  "errorMessage": errorMessage,
                                  "errorCode": errorCode]
        
        return resultAsJSON
    }
    
}


@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class GetBlockedListResponse: GetBlockedUserListModel {
    
}
