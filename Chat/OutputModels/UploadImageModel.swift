//
//  UploadImageModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UploadImageModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError          Bool
     *  - errorMessage      String
     *  - errorCode         Int
     *  + result       JSON or UploadImageModel:
     *      + UploadImage   UploadImageAsJSON:
     *          - actualHeight  Int?
     *          - actualWidth   Int?
     *          - hashCode      String?
     *          - height        Int?
     *          - id            Int?
     *          - name          String?
     *          - width         Int?
     ---------------------------------------
     * responseAsModel:
     *  - hasError          Bool
     *  - errorMessage      String
     *  - errorCode         Int
     *  + user              User
     ---------------------------------------
     */
    
    // uploadImage model properties
    public let hasError:           Bool
    public let errorMessage:       String
    public let errorCode:          Int
    public let uploadImage:        UploadImage
    
    public var uploadImageJSON: JSON = []
    
    init(messageContent: JSON, hasError: Bool, errorMessage: String, errorCode: Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        self.uploadImage = UploadImage(messageContent: messageContent)
        self.uploadImageJSON = uploadImage.formatToJSON()
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["uploadImage": uploadImageJSON]
        
        let resultAsJSON: JSON = ["result": result,
                                  "hasError": hasError,
                                  "errorMessage": errorMessage,
                                  "errorCode": errorCode]
        
        return resultAsJSON
    }
    
}

