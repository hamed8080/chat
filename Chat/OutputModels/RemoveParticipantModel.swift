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
    public let hasError:           Bool
    public let errorMessage:       String
    public let errorCode:          Int
    public let contentCount:       Int
    
    // result model
    public var contacts:           [Participant] = []
    
    public var contactsJSON:       [JSON] = []
    
    init(messageContent: JSON, hasError: Bool, errorMessage: String, errorCode: Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        self.contentCount       = messageContent["contentCount"].intValue
        
        if let result = messageContent["result"].array {
            for item in result {
                let tempContact = Participant(messageContent: item)
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


