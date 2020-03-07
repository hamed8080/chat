//
//  QueueOfWaitFileMessagesModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class QueueOfWaitFileMessagesModel {
    
    let content:        String?
    let messageType:    MESSAGE_TYPE
    let fileName:       String?
//    let imageName:      String?
//    let metadata:       JSON?
    let metadata:       String?
    let repliedTo:      Int?
    let threadId:       Int?
    let xC:             Int?
    let yC:             Int?
    let hC:             Int?
    let wC:             Int?
    let fileToSend:     Data?
    let imageToSend:    Data?
    
    let typeCode:    String?
    let uniqueId:    String?
    
    init(content:       String?,
         messageType:   MESSAGE_TYPE,
         fileName:      String?,
//         imageName:     String?,
//         metadata:      JSON?,
         metadata:      String?,
         repliedTo:     Int?,
         threadId:      Int?,
         xC:            Int?,
         yC:            Int?,
         hC:            Int?,
         wC:            Int?,
         fileToSend:    Data?,
         imageToSend:   Data?,
         typeCode:      String?,
         uniqueId:      String?) {
        
        self.content        = content
        self.messageType    = messageType
        self.fileName       = fileName
//        self.imageName      = imageName
        self.metadata       = metadata
        self.repliedTo      = repliedTo
        self.threadId       = threadId
        self.xC             = xC
        self.yC             = yC
        self.hC             = hC
        self.wC             = wC
        self.fileToSend     = fileToSend
        self.imageToSend    = imageToSend
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId
    }
    
    init(fileMessageInputModel: SendFileMessageRequestModel, uniqueId: String) {
        
        self.content        = fileMessageInputModel.messageInput.content
        self.messageType    = fileMessageInputModel.messageInput.messageType
        self.metadata       = (fileMessageInputModel.messageInput.metadata != nil) ? "\(fileMessageInputModel.messageInput.metadata!)" : nil
        self.repliedTo      = fileMessageInputModel.messageInput.repliedTo
        self.threadId       = fileMessageInputModel.messageInput.threadId
        self.typeCode       = fileMessageInputModel.messageInput.typeCode
        self.uniqueId       = uniqueId
        
        self.fileName       = fileMessageInputModel.uploadInput.fileName
        if let file = fileMessageInputModel.uploadInput as? UploadFileRequestModel {
            self.xC             = nil
            self.yC             = nil
            self.hC             = nil
            self.wC             = nil
            self.fileToSend     = file.dataToSend
            self.imageToSend    = nil
        } else if let image = fileMessageInputModel.uploadInput as? UploadImageRequestModel {
            self.xC             = image.xC
            self.yC             = image.yC
            self.hC             = image.hC
            self.wC             = image.wC
            self.fileToSend     = nil
            self.imageToSend    = image.dataToSend
        } else {
            self.xC             = nil
            self.yC             = nil
            self.hC             = nil
            self.wC             = nil
            self.fileToSend     = nil
            self.imageToSend    = nil
        }
        
//        self.content        = fileMessageInputModel.content
//        self.fileName       = fileMessageInputModel.fileName
////        self.imageName      = fileMessageInputModel.imageName
////        self.metadata       = fileMessageInputModel.metadata
//        self.metadata       = (fileMessageInputModel.metadata != nil) ? "\(fileMessageInputModel.metadata!)" : nil
//        self.repliedTo      = fileMessageInputModel.repliedTo
//        self.threadId       = fileMessageInputModel.threadId
//        self.xC             = fileMessageInputModel.xC
//        self.yC             = fileMessageInputModel.yC
//        self.hC             = fileMessageInputModel.hC
//        self.wC             = fileMessageInputModel.wC
//        self.fileToSend     = fileMessageInputModel.fileToSend
//        self.imageToSend    = fileMessageInputModel.imageToSend
//
//        self.typeCode       = fileMessageInputModel.typeCode
//        self.uniqueId       = uniqueId
    }
    
    
    public func returnDataAsJSONAndData() -> (jsonResult: JSON, imageToSend: Data?, fileToSend: Data?) {
        let result: JSON = ["content":      content ?? NSNull(),
                            "messageType":  messageType,
                            "fileName":     fileName ?? NSNull(),
//                            "imageName":    imageName ?? NSNull(),
                            "metadata":     metadata ?? NSNull(),
                            "repliedTo":    repliedTo ?? NSNull(),
                            "threadId":     threadId ?? NSNull(),
                            "xC":           xC ?? NSNull(),
                            "yC":           yC ?? NSNull(),
                            "hC":           hC ?? NSNull(),
                            "wC":           wC ?? NSNull(),
                            "typeCode":     typeCode ?? NSNull(),
                            "uniqueId":     uniqueId ?? NSNull()]
        return (result, imageToSend, fileToSend)
    }
    
    
}
