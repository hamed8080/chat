//
//  DownloadImageModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/24/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class DownloadImageModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError          Bool
     *  - errorMessage      String
     *  - errorCode         Int
     *  + result            ImageObject:
     *      + DownloadImage   ImageObjectAsJSON:
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
    public let errorCode:           Int
    public let errorMessage:        String
    public let hasError:            Bool
    public let downloadImage:       ImageObject?
    
    public init(messageContentJSON: JSON?,
                errorCode:      Int,
                errorMessage:   String,
                hasError:       Bool) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        if let content = messageContentJSON {
            self.downloadImage = ImageObject(messageContent: content)
        } else {
            downloadImage = nil
        }
        
    }
    
    public init(messageContentModel: ImageObject?,
                errorCode:      Int,
                errorMessage:   String,
                hasError:       Bool) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        if let myImage = messageContentModel {
            self.downloadImage    = myImage
        } else {
            downloadImage = nil
        }
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["downloadImage":    downloadImage?.formatToJSON() ?? NSNull()]
        
        let resultAsJSON: JSON = ["result":     result,
                                  "errorCode":  errorCode,
                                  "errorMessage": errorMessage,
                                  "hasError":   hasError]
        
        return resultAsJSON
    }
    
}
