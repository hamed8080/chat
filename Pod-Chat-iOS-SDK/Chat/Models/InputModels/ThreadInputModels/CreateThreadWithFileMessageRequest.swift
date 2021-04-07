//
//  CreateThreadWithFileMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/11/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class CreateThreadWithFileMessageRequest {
    
    public let creatThreadWithMessageInput:    CreateThreadWithMessageRequest
    public let uploadInput:                    UploadRequest
    
    public init(creatThreadWithMessageInput:   CreateThreadWithMessageRequest,
                uploadInput:                   UploadRequest) {
        
        self.creatThreadWithMessageInput    = creatThreadWithMessageInput
        self.uploadInput                    = uploadInput
    }
    
}


/// MARK: -  this class will be deprecate (use this class instead: 'CreateThreadWithFileMessageRequest')
@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class CreateThreadWithFileMessageRequestModel: CreateThreadWithFileMessageRequest {
    
}
