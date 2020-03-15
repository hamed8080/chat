//
//  JoinThreadRequestModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/21/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class JoinThreadRequestModel {
    
    public let uniqueName:  String
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(uniqueName: String,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.uniqueName = uniqueName
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
//    func convertContentToJSON() -> JSON {
//        var content: JSON = [:]
//        content["uniqueName"] = JSON(self.uniqueName)
//        return content
//    }
    
}

