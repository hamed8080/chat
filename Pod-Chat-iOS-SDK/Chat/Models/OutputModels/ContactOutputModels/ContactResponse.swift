//
//  ContactResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class ContactResponse: ResponseModel, ResponseModelDelegates {
    
    public var contentCount:       Int = 0
    public var contacts:           [Contact] = []
    
    public init(messageContent: JSON) {
        
        if let result = messageContent["result"].array {
            for item in result {
                let tempContact = Contact(messageContent: item)
                self.contacts.append(tempContact)
            }
        }
        self.contentCount = messageContent["count"].intValue
        super.init(hasError:        messageContent["hasError"].bool ?? false,
                   errorMessage:    messageContent["message"].string ?? "",
                   errorCode:       messageContent["errorCode"].int ?? 0)
    }
    
    public init(contentCount:   Int,
                messageContent: [Contact]?,
                hasError:       Bool,
                errorMessage:   String?,
                errorCode:      Int?) {
        
        if let result = messageContent {
            for item in result {
                self.contacts.append(item)
            }
        }
        self.contentCount = contentCount
        super.init(hasError:        hasError,
                   errorMessage:    errorMessage ?? "",
                   errorCode:       errorCode ?? 0)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        var contactArr = [JSON]()
        for item in contacts {
            contactArr.append(item.formatToJSON())
        }
        let result: JSON = ["contacts":     contactArr,
                            "contentCount": contentCount]
        
        let finalResult: JSON = ["result":      result,
                                 "hasError":    hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode":   errorCode]
        
        return finalResult
    }
}


open class ContactModel: ContactResponse {
    
}
