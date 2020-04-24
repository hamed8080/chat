//
//  DeleteMessageRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class DeleteMessageRequest: RequestModelDelegates {
    
    public let deleteForAll:    Bool?
    public let messageId:       Int
    public let typeCode:    String?
    public let uniqueId:    String
    
    // this variable will be deprecated soon, (use 'messageId' instead)
    public let subjectId: Int
    
    public init(deleteForAll:   Bool?,
                messageId:      Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.deleteForAll   = deleteForAll
        self.messageId      = messageId
        
        self.subjectId      = messageId
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    public init(deleteForAll:   Bool?,
                subjectId:      Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.deleteForAll   = deleteForAll
        self.messageId      = subjectId
        
        self.subjectId      = subjectId
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = []
        if let deleteForAll = self.deleteForAll {
            content["deleteForAll"] = JSON("\(deleteForAll)")
        }
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}


/// MARK: -  this class will be deprecate (use this class instead: 'DeleteMessageRequest')
open class DeleteMessageRequestModel: DeleteMessageRequest {
    
}
