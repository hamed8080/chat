//
//  CreateThreadWithFileMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/11/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class CreateThreadWithFileMessageRequest {
    
    public let creatThreadWithMessageInput:    CreateThreadWithMessageRequestModel
    public let uploadInput:                    UploadRequest
    
    public init(creatThreadWithMessageInput:   CreateThreadWithMessageRequestModel,
                uploadInput:                   UploadRequest) {
        
        self.creatThreadWithMessageInput    = creatThreadWithMessageInput
        self.uploadInput                    = uploadInput
    }
    
}


/// MARK: -  this class will be deprecate (use this class instead: 'CreateThreadWithFileMessageRequest')
open class CreateThreadWithFileMessageRequestModel: CreateThreadWithFileMessageRequest {
    
}
