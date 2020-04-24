//
//  UploadRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/14/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class UploadRequest {
    
    public let dataToSend:          Data    //= Data()
    public let fileExtension:       String? //= nil
    public let fileName:            String  //= ""
    public let fileSize:            Int64   //= 0
    public let mimeType:            String
    public let originalFileName:    String  //= ""
    public let threadId:            Int?    //= nil
    
    public let typeCode:            String? //= nil
    public let uniqueId:            String  //= ""
    
    public let xC:                  Int?    //= nil
    public let yC:                  Int?    //= nil
    public let hC:                  Int?    //= nil
    public let wC:                  Int?    //= nil
    
    
    /// initializer of Uploading File request model
    public init(dataToSend:         Data,
                fileExtension:      String?,
                fileName:           String?,
                mimeType:           String?,
                originalFileName:   String?,
                threadId:           Int?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        let theFileName = fileName ?? "\(NSUUID().uuidString))"
        
        self.dataToSend         = dataToSend
        self.fileExtension      = fileExtension
        self.fileName           = theFileName
        self.fileSize           = Int64(dataToSend.count)
        self.mimeType           = mimeType ?? ""
        self.originalFileName   = originalFileName ?? theFileName
        self.threadId           = threadId
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? NSUUID().uuidString
        
        self.xC                 = nil
        self.yC                 = nil
        self.hC                 = nil
        self.wC                 = nil
    }
    
    /// initializer of Uploading Image request model
    public init(dataToSend:         Data,
                fileExtension:      String?,
                fileName:           String?,
                mimeType:           String?,
                originalFileName:   String?,
                threadId:           Int?,
                xC:                 Int?,
                yC:                 Int?,
                hC:                 Int?,
                wC:                 Int?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        let theFileName:           String  = fileName ?? "\(NSUUID().uuidString))"
        
        self.dataToSend         = dataToSend
        self.fileExtension      = fileExtension
        self.fileName           = theFileName
        self.fileSize           = Int64(dataToSend.count)
        self.mimeType           = mimeType ?? ""
        self.originalFileName   = originalFileName ?? theFileName
        self.threadId           = threadId
        self.xC                 = xC
        self.yC                 = yC
        self.hC                 = hC
        self.wC                 = wC
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? NSUUID().uuidString
    }
    
}


open class UploadRequestModel: UploadRequest {
    
}
