//
//  GetContactsResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class GetContactsModel: ResponseModel, ResponseModelDelegates {
    
    public var contentCount:       Int = 0
    public var hasNext:            Bool = false
    public var nextOffset:         Int = 0
    public var contacts:           [Contact] = []
    
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
            let cont = Contact(messageContent: item)
            contacts.append(cont)
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(contactsObject:    [Contact],
                contentCount:      Int,
                count:             Int,
                offset:            Int,
                hasError:          Bool,
                errorMessage:      String,
                errorCode:         Int) {
        
        let messageLength = contactsObject.count
        self.contentCount = contentCount
        self.hasNext = false
        let x: Int = count + offset
        if (x < contentCount) && (messageLength > 0) {
            self.hasNext = true
        }
        self.nextOffset = offset + messageLength
        
        for item in contactsObject {
            contacts.append(item)
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        var contactArr = [JSON]()
        for item in contacts {
            contactArr.append(item.formatToJSON())
        }
        let result: JSON = ["contentCount": contentCount,
                            "hasNext":      hasNext,
                            "nextOffset":   nextOffset,
                            "contacts":     contactArr]
        
        let finalResult: JSON = ["result": result,
                                 "hasError": hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode": errorCode]
        
        return finalResult
    }
    
}

@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class GetContactsResponse: GetContactsModel {
    
}

