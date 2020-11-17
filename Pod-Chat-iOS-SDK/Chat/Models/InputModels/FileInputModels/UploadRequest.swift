//
//  UploadRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/14/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class UploadRequest {
    
    public var dataToSend:          Data    = Data()
    public var fileExtension:       String? = nil
    public var fileName:            String  = ""
    public var fileSize:            Int64   = 0
    public var isPublic:            Bool?   = nil
    public var mimeType:            String  = ""
    public var originalName:        String  = ""
    public var userGroupHash:       String? = nil
    
    public let typeCode:            String? //= nil
    public let uniqueId:            String  //= ""
    
    public var xC:                  Int     = 0
    public var yC:                  Int     = 0
    public var hC:                  Int     = 0
    public var wC:                  Int     = 0
    
    
    init(typeCode:  String?,
         uniqueId:  String?) {
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? NSUUID().uuidString
    }
    
//    /// initializer of Uploading File request model
//    public init(dataToSend:         Data,
////                fileExtension:      String?,
//                fileName:           String?,
////                mimeType:           String?,
////                originalFileName:   String?,
////                threadId:           Int?,
//                userGroupHash:      String,
//                typeCode:           String?,
//                uniqueId:           String?) {
//        
//        let theFileName = fileName ?? "\(NSUUID().uuidString))"
//        
//        self.dataToSend         = dataToSend
////        self.fileExtension      = fileExtension
//        self.fileName           = theFileName
////        self.fileSize           = Int64(dataToSend.count)
////        self.mimeType           = mimeType ?? ""
////        self.originalFileName   = originalFileName ?? theFileName
////        self.threadId           = threadId
//        self.userGroupHash      = userGroupHash
//        self.typeCode           = typeCode
//        self.uniqueId           = uniqueId ?? NSUUID().uuidString
//        
//        self.xC                 = nil
//        self.yC                 = nil
//        self.hC                 = nil
//        self.wC                 = nil
//    }
    
//    /// initializer of Uploading Image request model
//    public init(dataToSend:         Data,
////                fileExtension:      String?,
//                fileName:           String?,
////                mimeType:           String?,
////                originalFileName:   String?,
////                threadId:           Int?,
//                xC:                 Int?,
//                yC:                 Int?,
//                hC:                 Int?,
//                wC:                 Int?,
//                userGroupHash:      String,
//                typeCode:           String?,
//                uniqueId:           String?) {
//
//        let theFileName:           String  = fileName ?? "\(NSUUID().uuidString))"
//
//        self.dataToSend         = dataToSend
////        self.fileExtension      = fileExtension
//        self.fileName           = theFileName
////        self.fileSize           = Int64(dataToSend.count)
////        self.mimeType           = mimeType ?? ""
////        self.originalFileName   = originalFileName ?? theFileName
////        self.threadId           = threadId
//        self.xC                 = xC
//        self.yC                 = yC
//        self.hC                 = hC
//        self.wC                 = wC
//        self.userGroupHash      = userGroupHash
//        self.typeCode           = typeCode
//        self.uniqueId           = uniqueId ?? NSUUID().uuidString
//    }
    
}


open class UploadRequestModel: UploadRequest {
    
}
