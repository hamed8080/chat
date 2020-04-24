//
//  ResponseModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class ResponseModel {
    
    var hasError:       Bool
    var errorMessage:   String
    var errorCode:      Int
    
    public init(hasError: Bool,
                errorMessage: String,
                errorCode: Int) {
        
        self.hasError           = hasError
        self.errorMessage       = errorMessage
        self.errorCode          = errorCode
    }
    
}

