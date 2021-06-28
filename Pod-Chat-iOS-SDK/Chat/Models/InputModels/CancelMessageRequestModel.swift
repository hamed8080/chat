//
//  CancelMessageRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 2/26/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class CancelMessageRequest {
    
    public let textMessageUniqueId:     String?
    public let editMessageUniqueId:     String?
    public let forwardMessageUniqueId:  String?
    public let fileMessageUniqueId:     String?
    public let uploadImageUniqueId:     String?
    public let uploadFileUniqueId:      String?
    
    public init(textMessageUniqueId:    String?,
                editMessageUniqueId:    String?,
                forwardMessageUniqueId: String?,
                fileMessageUniqueId:    String?,
                uploadImageUniqueId:    String?,
                uploadFileUniqueId:     String?) {
        
        self.textMessageUniqueId    = textMessageUniqueId
        self.editMessageUniqueId    = editMessageUniqueId
        self.forwardMessageUniqueId = forwardMessageUniqueId
        self.fileMessageUniqueId    = fileMessageUniqueId
        self.uploadImageUniqueId    = uploadImageUniqueId
        self.uploadFileUniqueId     = uploadFileUniqueId
    }
    
}


@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class CancelMessageRequestModel: CancelMessageRequest {
    
}
