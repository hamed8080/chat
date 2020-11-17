//
//  UploadImageRequest.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

open class UploadImageRequest: UploadRequest {
    
    /// initializer of Uploading Image request model
    public init(dataToSend:     Data,
                fileExtension:  String?,
                fileName:       String?,
                mimeType:       String?,
                originalName:   String?,
                xC:             Int?,
                yC:             Int?,
                hC:             Int?,
                wC:             Int?,
                userGroupHash:  String,
                typeCode:       String?,
                uniqueId:       String?) {
        super.init(typeCode: typeCode, uniqueId: uniqueId)
        
        self.dataToSend     = dataToSend
        self.fileExtension  = fileExtension
        self.fileName       = fileName ?? "\(NSUUID().uuidString))"
        self.fileSize       = Int64(dataToSend.count)
        self.mimeType       = mimeType ?? ""
        self.userGroupHash  = userGroupHash
        self.originalName   = originalName ?? (self.fileName + (fileExtension ?? ""))
        
        if let image = UIImage(data: dataToSend) {
            self.xC = xC ?? 0
            self.yC = yC ?? 0
            self.hC = hC ?? Int(image.size.height)
            self.wC = wC ?? Int(image.size.width)
        }
        
    }
    
    // only use this initializer on, createThreadWithFileMessage & sendFileMessage methods
    public init(dataToSend:     Data,
                fileExtension:  String?,
                fileName:       String?,
                mimeType:       String?,
                originalName:   String?,
                xC:             Int?,
                yC:             Int?,
                hC:             Int?,
                wC:             Int?,
                typeCode:       String?,
                uniqueId:       String?) {
        super.init(typeCode: typeCode, uniqueId: uniqueId)
        
        self.dataToSend     = dataToSend
        self.fileExtension  = fileExtension
        self.fileName       = fileName ?? "\(NSUUID().uuidString))"
        self.fileSize       = Int64(dataToSend.count)
        self.mimeType       = mimeType ?? ""
        self.userGroupHash  = userGroupHash
        self.originalName   = originalName ?? (self.fileName + (fileExtension ?? ""))
        
        if let image = UIImage(data: dataToSend) {
            self.xC = xC ?? 0
            self.yC = yC ?? 0
            self.hC = hC ?? Int(image.size.height)
            self.wC = wC ?? Int(image.size.width)
        }
        
    }
    
    /// initializer of Uploading Public Image request model
    public init(dataToSend:     Data,
                fileExtension:  String?,
                fileName:       String?,
                isPublic:       Bool,
                mimeType:       String?,
                originalName:   String?,
                xC:             Int?,
                yC:             Int?,
                hC:             Int?,
                wC:             Int?,
                typeCode:       String?,
                uniqueId:       String?) {
        super.init(typeCode: typeCode, uniqueId: uniqueId)
        
        self.dataToSend     = dataToSend
        self.fileExtension  = fileExtension
        self.fileName       = fileName ?? "\(NSUUID().uuidString))"
        self.fileSize       = Int64(dataToSend.count)
        self.isPublic       = isPublic
        self.mimeType       = mimeType ?? ""
        self.originalName   = originalName ?? (self.fileName + (fileExtension ?? ""))
//        self.xC             = xC
//        self.yC             = yC
//        self.hC             = hC
//        self.wC             = wC
        if let image = UIImage(data: dataToSend) {
            self.xC = xC ?? 0
            self.yC = yC ?? 0
            self.hC = hC ?? Int(image.size.height)
            self.wC = wC ?? Int(image.size.width)
        }
    }
    
    
    func convertContentToParameters() -> Parameters {
        
        var content: Parameters = [:]
        content["filename"]         = JSON(self.fileName)
        
        if let isPublic_ = isPublic {
            content["isPublic"]    = JSON(isPublic_)
        }
        if let userGroupHash_ = userGroupHash {
            content["userGroupHash"]    = JSON(userGroupHash_)
        }
        
        content["xC"] = JSON(xC)
        content["yC"] = JSON(yC)
        content["hC"] = JSON(hC)
        content["wC"] = JSON(wC)
//        if let xC_ = self.xC {
//            content["xC"] = JSON(xC_)
//        }
//        if let yC_ = self.yC {
//            content["yC"] = JSON(yC_)
//        }
//        if let hC_ = self.hC {
//            content["hC"] = JSON(hC_)
//        }
//        if let wC_ = self.wC {
//            content["wC"] = JSON(wC_)
//        }

        return content
    }
    
}


open class UploadImageRequestModel: UploadImageRequest {
    
}


