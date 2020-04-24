//
//  UpdateChatProfileRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import FanapPodAsyncSDK
import SwiftyJSON

open class UpdateChatProfileRequest: RequestModelDelegates {
    
    public let bio:         String?
    public let metadata:    String?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(bio:        String?,
                metadata:   String?,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.bio        = bio
        self.metadata   = metadata
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let myBio = bio {
            let theBio = MakeCustomTextToSend(message: myBio).replaceSpaceEnterWithSpecificCharecters()
            content["bio"] = JSON(theBio)
        }
        if let myMetadata = metadata {
            let theMeta = MakeCustomTextToSend(message: myMetadata).replaceSpaceEnterWithSpecificCharecters()
            content["metadata"] = JSON(theMeta)
        }
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}

/// MARK: -  this class will be deprecate.  (use this class instead: 'SetProfileRequest')
open class SetProfileRequestModel: UpdateChatProfileRequest {
    
}
