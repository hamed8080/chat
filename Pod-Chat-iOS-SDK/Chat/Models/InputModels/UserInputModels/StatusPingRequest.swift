//
//  StatusPingRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 6/22/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version.")
open class StatusPingRequest {
    
    public let chat:        Bool?
    public let contacts:    Bool?
    public let thread:      Bool?
    
    public let contactId:   Int?
    public let threadId:    Int?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(insideContact:  Bool,
                contactId:      Int?,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.chat       = nil
        self.contacts   = insideContact
        self.thread     = nil
        
        self.threadId   = nil
        
        self.contactId  = contactId
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public init(insideThread:   Bool,
                threadId:       Int?,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.chat       = nil
        self.contacts   = nil
        self.thread     = insideThread
        
        self.contactId  = nil
        
        self.threadId   = threadId
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    public init(insideChat: Bool,
                typeCode:   String?,
                uniqueId:   String?) {
        
        self.chat       = insideChat
        self.contacts   = nil
        self.thread     = nil
        
        self.contactId  = nil
        self.threadId   = nil
        self.typeCode   = typeCode
        self.uniqueId   = uniqueId ?? UUID().uuidString
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        if let _ = self.chat {
            content["location"] = JSON(1)
        }
        if let _ = self.thread {
            content["location"] = JSON(2)
        }
        if let _ = self.contacts {
            content["location"] = JSON(3)
        }
        if let threadId_ = self.threadId {
            content["location"] = JSON(2)
            content["locationId"] = JSON(threadId_)
        }
        if let contactId_ = self.contactId {
            content["location"] = JSON(3)
            content["locationId"] = JSON(contactId_)
        }
        return content
    }
    
}
