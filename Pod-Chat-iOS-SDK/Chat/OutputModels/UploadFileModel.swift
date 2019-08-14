//
//  UploadFileModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/5/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UploadFileModel {
    /*
     ---------------------------------------
     * responseAsJSON:
     *  - hasError          Bool
     *  - errorMessage      String
     *  - errorCode         Int
     *  + result       JSON or UploadFileModel:
     *      + UploadFile    UploadFileAsJSON
     *          - hashCode      String
     *          - id            Int
     *          - name          String
     ---------------------------------------
     * responseAsModel:
     *  - hasError          Bool
     *  - errorMessage      String
     *  - errorCode         Int
     *  + user              User
     ---------------------------------------
     */
    
    // uploadFile model properties
    public let errorCode:           Int
    public let errorMessage:        String
    public let hasError:            Bool
    //    public var localPath:           String = ""
    public let uploadFile:          UploadFile?
    
    public var uploadFileJSON: JSON = [:]
    
    public init(messageContentJSON: JSON?,
                errorCode:      Int,
                errorMessage:   String,
                hasError:       Bool/*,
         localPath:      String?*/) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        //        if let pathString = localPath {
        //            self.localPath = pathString
        //        }
        
        if let myFile = messageContentJSON {
            self.uploadFile = UploadFile(messageContent: myFile)
        } else {
            self.uploadFile = nil
        }
        
    }
    
    public init(messageContentModel: UploadFile?,
                errorCode:      Int,
                errorMessage:   String,
                hasError:       Bool/*,
         localPath:      String?*/) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
        
        //        if let pathString = localPath {
        //            self.localPath = pathString
        //        }
        
        if let myFile = messageContentModel {
            self.uploadFile = myFile
        } else {
            self.uploadFile = nil
        }
        
    }
    
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["uploadFile":   uploadFile?.formatToJSON() ?? NSNull()]
        
        let resultAsJSON: JSON = ["result":     result,
                                  "errorCode":  errorCode,
                                  "errorMessage": errorMessage,
                                  "hasError":   hasError/*,
             "localPath": localPath*/]
        
        return resultAsJSON
    }
    
}
