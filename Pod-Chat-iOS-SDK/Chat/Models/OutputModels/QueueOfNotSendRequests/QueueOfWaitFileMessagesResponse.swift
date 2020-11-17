//
//  QueueOfWaitFileMessagesResponse.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 11/27/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class QueueOfWaitFileMessagesModel {
    
    let textMessage:    String?
    let messageType:    MessageType
    let fileExtension:  String?
    let fileName:       String?
    let isPublic:       Bool?
    let metadata:       String?
    let mimeType:       String
    let originalName:   String?
    let repliedTo:      Int?
    let threadId:       Int?
    let userGroupHash:  String?
    let xC:             Int?
    let yC:             Int?
    let hC:             Int?
    let wC:             Int?
    let fileToSend:     Data?
    let imageToSend:    Data?
    
    let typeCode:    String?
    let uniqueId:    String?
    
    init(textMessage:   String?,
         messageType:   MessageType,
         fileExtension: String?,
         fileName:      String?,
         isPublic:      Bool?,
         metadata:      String?,
         mimeType:      String?,
         originalName:  String?,
         repliedTo:     Int?,
         threadId:      Int?,
         userGroupHash: String?,
         xC:            Int?,
         yC:            Int?,
         hC:            Int?,
         wC:            Int?,
         fileToSend:    Data?,
         imageToSend:   Data?,
         typeCode:      String?,
         uniqueId:      String?) {
        
        self.textMessage    = textMessage
        self.messageType    = messageType
        self.fileExtension  = fileExtension
        self.fileName       = fileName
        self.isPublic       = isPublic
        self.metadata       = metadata
        self.mimeType       = mimeType ?? ""
        self.originalName   = originalName ?? ((fileName ?? "") + (fileExtension ?? ""))
        self.repliedTo      = repliedTo
        self.threadId       = threadId
        self.userGroupHash  = userGroupHash
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
        
        self.textMessage    = fileMessageInputModel.messageInput.textMessage
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
            self.imageToSend    = nil
            self.fileExtension  = file.fileExtension
            self.fileToSend     = file.dataToSend
            self.isPublic       = file.isPublic
            self.mimeType       = file.mimeType
            self.originalName   = file.originalName
            self.userGroupHash  = file.userGroupHash
        } else if let image = fileMessageInputModel.uploadInput as? UploadImageRequestModel {
            self.fileToSend     = nil
            self.xC             = image.xC
            self.yC             = image.yC
            self.hC             = image.hC
            self.wC             = image.wC
            self.fileExtension  = image.fileExtension
            self.imageToSend    = image.dataToSend
            self.isPublic       = image.isPublic
            self.mimeType       = image.mimeType
            self.originalName   = image.originalName
            self.userGroupHash  = image.userGroupHash
        } else {
            self.xC             = nil
            self.yC             = nil
            self.hC             = nil
            self.wC             = nil
            self.fileExtension  = nil
            self.fileToSend     = nil
            self.imageToSend    = nil
            self.isPublic       = nil
            self.mimeType       = ""
            self.originalName   = nil
            self.userGroupHash  = nil
        }
        
    }
    
    
    public func returnDataAsJSONAndData() -> (jsonResult: JSON, imageToSend: Data?, fileToSend: Data?) {
        let result: JSON = ["textMessage":  textMessage ?? NSNull(),
                            "messageType":  messageType,
                            "fileExtension": fileExtension ?? NSNull(),
                            "fileName":     fileName ?? NSNull(),
                            "isPublic":     isPublic ?? NSNull(),
                            "metadata":     metadata ?? NSNull(),
                            "mimeType":     mimeType,
                            "originalName": originalName ?? NSNull(),
                            "repliedTo":    repliedTo ?? NSNull(),
                            "threadId":     threadId ?? NSNull(),
                            "userGroupHash": userGroupHash ?? NSNull(),
                            "xC":           xC ?? NSNull(),
                            "yC":           yC ?? NSNull(),
                            "hC":           hC ?? NSNull(),
                            "wC":           wC ?? NSNull(),
                            "typeCode":     typeCode ?? NSNull(),
                            "uniqueId":     uniqueId ?? NSNull()]
        return (result, imageToSend, fileToSend)
    }
    
}


open class QueueOfWaitFileMessagesResponse: QueueOfWaitFileMessagesModel {
    
}


