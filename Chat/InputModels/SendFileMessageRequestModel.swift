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
    public let threadId:    Int?
    
    public let subjectId:   Int?
    public let repliedTo:   Int?
    public let content:     String?
    public let metaData:    JSON?
    public let typeCode:    String?
    
    public let imageToSend: Data?
    public let fileToSend: Data?
    
    init(fileName:      String?,
         imageName:     String?,
         xC:            String?,
         yC:            String?,
         hC:            String?,
         wC:            String?,
         threadId:      Int?,
         subjectId:     Int?,
         repliedTo:     Int?,
         content:       String?,
         metaData:      JSON?,
         typeCode:      String?,
         imageToSend:   Data?,
         fileToSend:    Data?) {
        
        self.fileName       = fileName
        self.imageName      = imageName
        self.xC             = xC
        self.yC             = yC
        self.hC             = yC
        self.wC             = yC
        self.threadId       = threadId
        
        self.subjectId      = subjectId
        self.repliedTo      = repliedTo
        self.content        = content
        self.metaData       = metaData
        self.typeCode       = typeCode
        
        self.imageToSend    = imageToSend
        self.fileToSend     = fileToSend
    }
    
}

