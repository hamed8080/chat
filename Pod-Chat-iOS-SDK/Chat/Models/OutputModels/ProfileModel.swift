//
//  ProfileModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class ProfileModel {
    
    // user model properties
    public let hasError:        Bool
    public let errorMessage:    String
    public let errorCode:       Int
    
    public let profile:         Profile
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.profile           = Profile(messageContent: messageContent)
    }
    
    public init(profileObject:  Profile,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.hasError       = hasError
        self.errorMessage   = errorMessage
        self.errorCode      = errorCode
        
        self.profile        = profileObject
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["profile":     profile.formatToJSON()]
        
        let resultAsJSON: JSON = ["result":     result,
                                  "hasError":   hasError,
                                  "errorMessage": errorMessage,
                                  "errorCode":  errorCode]
        
        return resultAsJSON
    }
    
}
