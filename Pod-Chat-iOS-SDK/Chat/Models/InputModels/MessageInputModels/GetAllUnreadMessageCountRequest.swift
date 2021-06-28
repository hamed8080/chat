//
//  GetAllUnreadMessageCountRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class GetAllUnreadMessageCountRequest: RequestModelDelegates {
    
    public let countMuteThreads:    Bool?
    
    public let typeCode:            String?
    public let uniqueId:            String
    
    public init(countMuteThreads:   Bool?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        self.countMuteThreads   = countMuteThreads
        
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? UUID().uuidString
    }
    
    public init(json: JSON) {
        self.countMuteThreads   = json["mute"].bool
        
        self.typeCode           = json["typeCode"].string
        self.uniqueId           = json["uniqueId"].string ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let countMuteThreads_ = countMuteThreads {
            content["mute"] = JSON(countMuteThreads_)
        }
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class GetAllUnreadMessageCountRequestModel: GetAllUnreadMessageCountRequest {
    
}
