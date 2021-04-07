//
//  ProfileResponse.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class ProfileModel: ResponseModel, ResponseModelDelegates {
    
    public let profile: Profile
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.profile = Profile(messageContent: messageContent)
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(profileObject:  Profile,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.profile = profileObject
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public func returnDataAsJSON() -> JSON {
        let result: JSON = ["profile":  profile.formatToJSON()]
        
        let resultAsJSON: JSON = ["result":         result,
                                  "hasError":       hasError,
                                  "errorMessage":   errorMessage,
                                  "errorCode":      errorCode]
        
        return resultAsJSON
    }
    
}

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class ProfileResponse: ProfileModel {
    
}

