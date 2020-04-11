//
//  DeleteMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

import SwiftyJSON


open class DeleteMessageRequestModel {
    
    public let deleteForAll:    Bool?
    public let subjectId:       Int
//    public let messageId:           Int
    public let typeCode: String?
    public let uniqueId: String
    
    public init(deleteForAll:   Bool?,
                subjectId:      Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.deleteForAll   = deleteForAll
        self.subjectId      = subjectId
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = []
        if let deleteForAll = self.deleteForAll {
            content["deleteForAll"] = JSON("\(deleteForAll)")
        }
        
        return content
    }
    
}
