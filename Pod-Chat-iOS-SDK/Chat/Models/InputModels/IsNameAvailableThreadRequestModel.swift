//
//  IsNameAvailableThreadRequestModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON


open class IsNameAvailableThreadRequestModel {
    
    public let name:        String
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(name:       String,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.name       = name
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["name"] = JSON(self.name)
        return content
    }
    
}
