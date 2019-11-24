//
//  GetThreadsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

import SwiftyJSON


open class GetThreadsRequestModel {
    
    public let count:                   Int?    // count of threads to be received (default value is 50)
    public let creatorCoreUserId:       Int?    // SSO User Id of thread creator
    public let metadataCriteria:        JSON?   //
    public let name:                    String? // Search term to look up in thread Titles
    public let new:                     Bool?   //
    public let offset:                  Int?    // offset of select query (default value is 0)
    public let partnerCoreContactId:    Int?    // Contact Id of thread partner
    public let partnerCoreUserId:       Int?    // SSO User Id of thread partner
    public let threadIds:               [Int]?  // An array of thread ids to be received
    
    public let requestTypeCode:         String?
    public let requestUniqueId:         String?
    
    public init(count:                  Int?,
                creatorCoreUserId:      Int?,
                metadataCriteria:       JSON?,
                name:                   String?,
                new:                    Bool?,
                offset:                 Int?,
                partnerCoreContactId:   Int?,
                partnerCoreUserId:      Int?,
                threadIds:              [Int]?,
                requestTypeCode:        String?,
                requestUniqueId:        String?) {
        
        self.count                  = count
        self.creatorCoreUserId      = creatorCoreUserId
        self.metadataCriteria       = metadataCriteria
        self.name                   = name
        self.new                    = new
        self.offset                 = offset
        self.partnerCoreContactId   = partnerCoreContactId
        self.partnerCoreUserId      = partnerCoreUserId
        self.threadIds              = threadIds
        self.requestTypeCode        = requestTypeCode
        self.requestUniqueId        = requestUniqueId
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["count"]    = JSON(self.count ?? 50)
        content["offset"]    = JSON(self.offset ?? 0)
        if let name = self.name {
            content["name"] = JSON(name)
        }
        if let new = self.new {
            content["new"] = JSON(new)
        }
        if let threadIds = self.threadIds {
            content["threadIds"] = JSON(threadIds)
        }
        if let coreUserId = self.creatorCoreUserId {
            content["creatorCoreUserId"] = JSON(coreUserId)
        }
        if let coreUserId = self.partnerCoreUserId {
            content["partnerCoreUserId"] = JSON(coreUserId)
        }
        if let coreUserId = self.partnerCoreContactId {
            content["partnerCoreContactId"] = JSON(coreUserId)
        }
        if let metadataCriteria = self.metadataCriteria {
            content["metadataCriteria"] = JSON(metadataCriteria)
        }
        
        return content
    }
    
}


class GetAllThreadsRequestModel {
    
    public let summary:         Bool
    public let requestTypeCode: String?
    
    init(summary:           Bool,
         requestTypeCode:   String?) {
        self.summary            = summary
        self.requestTypeCode    = requestTypeCode
    }
    
    func convertContentToJSON() -> JSON {
        let content: JSON = ["summary": self.summary]
        return content
    }
    
}

