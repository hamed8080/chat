//
//  RemoveParticipantModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/13/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RemoveParticipantModel {
    
    // RemoveParticipant model properties
    let hasError:           Bool
    let errorMessage:       String
    let errorCode:          Int
    let contentCount:       Int
    
    // result model
    var contacts:           [Contact] = []
    
    var contactsJSON:       [JSON] = []
    
    init(messageContent: JSON, hasError: Bool, errorMessage: String, errorCode: Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        self.contentCount       = messageContent["contentCount"].intValue
        
        if let result = messageContent["result"].array {
            for item in result {
                let tempContact = Contact(messageContent: item)
                let tempContactJSON = tempContact.formatToJSON()
                
                self.contacts.append(tempContact)
                self.contactsJSON.append(tempContactJSON)
            }
        }
        
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["contacts": contactsJSON]
        
        let finalResult: JSON = ["result": result,
                                 "hasError": hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode": errorCode,
                                 "contentCount": contentCount]
        
        return finalResult
    }
}


