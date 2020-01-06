//
//  CreateThreadWithFileMessageRequestModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/11/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class CreateThreadWithFileMessageRequestModel {
    
    public let creatThreadWithMessageInput:    CreateThreadWithMessageRequestModel
    public let uploadInput:                    UploadRequestModel
    
    public init(creatThreadWithMessageInput:   CreateThreadWithMessageRequestModel,
         uploadInput:                   UploadRequestModel) {
        
        self.creatThreadWithMessageInput    = creatThreadWithMessageInput
        self.uploadInput                    = uploadInput
    }
    
}
