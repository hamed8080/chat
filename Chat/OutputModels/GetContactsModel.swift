//
//  GetContactsModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class GetContactsModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  + result            [JSON]:
     *      - contentCount      Int
     *      - hasNext           Bool
     *      - nextOffset        Int
     *      + contacts          ContactsAsJSON
     *          - cellphoneNumber     String?
     *          - email               String?
     *          - firstName           String?
     *          - hasUser             Bool?
     *          - id                  Int?
     *          - image               String?
     *          - lastName            String?
     *          - linkedUser          LinkedUser?
     *          - notSeenDuration     Int?
     *          - uniqueId            Bool?
     *          - userId              Int?
     ---------------------------------------
     * responseAsModel:
     *  - hasError      Bool
     *  - errorMessage  String
     *  - errorCode     Int
     *  + result
     *      - contacts       [Contact]
     ---------------------------------------
     */
    
    // GetContact model properties
    public let hasError:           Bool
    public let errorMessage:       String
    public let errorCode:          Int
    
    // result model
    public var contentCount:       Int = 0
    public var hasNext:            Bool = false
    public var nextOffset:         Int = 0
    public var contacts:           [Contact] = []
    
    public var contacrsJSON:       [JSON] = []
    
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
            let cont = Contact(messageContent: item)
            let contJSON = cont.formatToJSON()
            
            contacts.append(cont)
            contacrsJSON.append(contJSON)
        }
        
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["contentCount": contentCount,
                            "hasNext":      hasNext,
                            "nextOffset":   nextOffset,
                            "contacts":     contacrsJSON]
        
        let finalResult: JSON = ["result": result,
                                 "hasError": hasError,
                                 "errorMessage": errorMessage,
                                 "errorCode": errorCode]
        
        return finalResult
    }
    
}


