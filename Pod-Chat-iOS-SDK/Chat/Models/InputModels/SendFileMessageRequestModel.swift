//
//  SendFileMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

import SwiftyJSON


open class SendFileMessageRequestModel {
    
    let messageInput:   SendTextMessageRequestModel
    let uploadInput:    UploadRequestModel
    
    public init(messageInput:   SendTextMessageRequestModel,
                uploadInput:    UploadRequestModel) {
        
        self.messageInput   = messageInput
        self.uploadInput    = uploadInput
    }
    
    
//    public let dataToSend:          Data    //= Data()
//    public let fileExtension:       String? //= nil
//    public let fileName:            String  //= ""
//    public let fileSize:            Int64   //= 0
//    public let originalFileName:    String  //= ""
//    public let threadId:            Int?    //= nil
//
//    public let typeCode:            String? //= nil
//    public let uniqueId:            String  //= ""
//
//    public let xC:                  Int?    //= nil
//    public let yC:                  Int?    //= nil
//    public let hC:                  Int?    //= nil
//    public let wC:                  Int?    //= nil
    
    
    
//    public let fileName:    String?
//    public let imageName:   String?
//    public let xC:          String?
//    public let yC:          String?
//    public let hC:          String?
//    public let wC:          String?
//    public let threadId:    Int
//
//    public let content:     String?
//    public let metadata:    JSON?
//    public let repliedTo:   Int?
//
//    public let fileToSend:      Data?
//    public let imageToSend:     Data?
//
//    public let typeCode: String?
//    public let uniqueId: String?
//
//    public init(fileName:       String?,
//                imageName:      String?,
//                xC:             String?,
//                yC:             String?,
//                hC:             String?,
//                wC:             String?,
//                threadId:       Int,
//                content:        String?,
//                metadata:       JSON?,
//                repliedTo:      Int?,
//                fileToSend:     Data?,
//                imageToSend:    Data?,
//                typeCode:       String?,
//                uniqueId:       String?) {
//
//        self.fileName       = fileName
//        self.imageName      = imageName
//        self.xC             = xC
//        self.yC             = yC
//        self.hC             = yC
//        self.wC             = yC
//        self.threadId       = threadId
//
//        self.content        = content
//        self.metadata       = metadata
//        self.repliedTo      = repliedTo
//
//        self.fileToSend     = fileToSend
//        self.imageToSend    = imageToSend
//
//        self.typeCode       = typeCode
//        self.uniqueId       = uniqueId
//    }
    
}

