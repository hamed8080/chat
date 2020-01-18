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
    
}

