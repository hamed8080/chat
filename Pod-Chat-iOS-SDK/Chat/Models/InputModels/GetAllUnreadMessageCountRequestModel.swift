//
//  GetAllUnreadMessageCountRequestModel.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/25/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class GetAllUnreadMessageCountRequestModel {
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(typeCode:   String?,
                uniqueId:   String?) {
        
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public init(json: JSON) {
        self.typeCode   = json["typeCode"].string
        self.uniqueId   = json["uniqueId"].string ?? UUID().uuidString
    }
    
//    func convertContentToJSON() -> JSON {
//        var content: JSON = [:]
//
//        return content
//    }
    
}
