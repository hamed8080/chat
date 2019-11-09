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
    
    public let fileName:    String?
    public let imageName:   String?
    public let xC:          String?
    public let yC:          String?
    public let hC:          String?
    public let wC:          String?
    public let threadId:    Int
    
    public let content:     String?
    public let metaData:    JSON?
    public let repliedTo:   Int?
    
    public let fileToSend:      Data?
    public let imageToSend:     Data?
    
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(fileName:           String?,
                imageName:          String?,
                xC:                 String?,
                yC:                 String?,
                hC:                 String?,
                wC:                 String?,
                threadId:           Int,
                content:            String?,
                metaData:           JSON?,
                repliedTo:          Int?,
                fileToSend:         Data?,
                imageToSend:        Data?,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.fileName       = fileName
        self.imageName      = imageName
        self.xC             = xC
        self.yC             = yC
        self.hC             = yC
        self.wC             = yC
        self.threadId       = threadId
        
        self.content        = content
        self.metaData       = metaData
        self.repliedTo      = repliedTo
        
        self.fileToSend     = fileToSend
        self.imageToSend    = imageToSend
        
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
}

