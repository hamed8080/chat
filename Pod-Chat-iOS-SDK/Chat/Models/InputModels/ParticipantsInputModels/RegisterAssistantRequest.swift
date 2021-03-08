//
//  RegisterAssistantRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/9/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class RegisterAssistantRequest {
    
    public let assistants: [AssistantVO]
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(assistants:     [AssistantVO],
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.assistants = assistants
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    
    public func convertContentToJSON() -> [JSON] {
        var contents = [JSON]()
        
        for assist in assistants {
            var content: JSON = [:]
            if let assistant = assist.assistant {
                content["assistant"] = assistant.formatToJSON()
            }
            if let roleTypes = assist.roleTypes {
                var tempRoles = [String]()
                for item in roleTypes {
                    tempRoles.append(item.stringValue())
                }
                content["roleTypes"] = JSON(tempRoles)
            }
            if let contactType = assist.contactType {
                content["contactType"] = JSON(contactType)
            }
            
            contents.append(content)
        }
        
        return contents
    }
    
}



open class DeactiveAssistantRequest {
    
    public let assistants:  [Invitee]
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(assistants:     [Invitee],
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.assistants     = assistants
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    
    public func convertContentToJSON() -> [JSON] {
        var contents = [JSON]()
        
        for item in assistants {
            var content: JSON = [:]
            content["assistant"] = item.formatToJSON()
            contents.append(content)
        }
        
        return contents
    }
    
}



open class GetAssistantsRequest {
    
    public let contactType: String
    public let count:       Int?
    public let offset:      Int?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(contactType:    String,
                count:          Int?,
                offset:         Int?,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.contactType    = contactType
        self.count          = count
        self.offset         = offset
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        
        content["contactType"] = JSON(contactType)
        if let count_ = count {
            content["count"] = JSON(count_)
        }
        if let offset_ = offset {
            content["offset"] = JSON(offset_)
        }
        
        return content
    }
    
}


open class GetAssistantsHistoryRequest {
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(typeCode:       String?,
                uniqueId:       String?) {
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
}

