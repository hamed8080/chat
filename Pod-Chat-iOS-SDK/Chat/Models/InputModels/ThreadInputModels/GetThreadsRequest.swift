//
//  GetThreadsRequest.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodAsyncSDK
import SwiftyJSON

open class GetThreadsRequest: RequestModelDelegates {
    
    public let count:                   Int?    // count of threads to be received (default value is 50)
    public let creatorCoreUserId:       Int?    // SSO User Id of thread creator
    public let metadataCriteria:        String?   //
    public let new:                     Bool?   //
    public let offset:                  Int?    // offset of select query (default value is 0)
    public let partnerCoreContactId:    Int?    // Contact Id of thread partner
    public let partnerCoreUserId:       Int?    // SSO User Id of thread partner
    public let threadIds:               [Int]?  // An array of thread ids to be received
    public let threadName:              String? // Search term to look up in thread Titles
    
    public let typeCode:                String?
    public let uniqueId:                String
    
    public init(count:                  Int?,
                creatorCoreUserId:      Int?,
                metadataCriteria:       String?,
                new:                    Bool?,
                offset:                 Int?,
                partnerCoreContactId:   Int?,
                partnerCoreUserId:      Int?,
                threadIds:              [Int]?,
                threadName:             String?,
                typeCode:               String?,
                uniqueId:               String?) {
        
        self.count                  = count
        self.creatorCoreUserId      = creatorCoreUserId
        self.metadataCriteria       = metadataCriteria
        self.new                    = new
        self.offset                 = offset
        self.partnerCoreContactId   = partnerCoreContactId
        self.partnerCoreUserId      = partnerCoreUserId
        self.threadIds              = threadIds
        self.threadName             = threadName
        
        self.typeCode               = typeCode
        self.uniqueId               = uniqueId ?? UUID().uuidString
    }
    
    public init(count:                  Int?,
                creatorCoreUserId:      Int?,
                metadataCriteria:       String?,
                name:                   String?,
                new:                    Bool?,
                offset:                 Int?,
                partnerCoreContactId:   Int?,
                partnerCoreUserId:      Int?,
                threadIds:              [Int]?,
                typeCode:               String?,
                uniqueId:               String?) {
        
        self.count                  = count
        self.creatorCoreUserId      = creatorCoreUserId
        self.metadataCriteria       = metadataCriteria
        self.threadName             = name
        self.new                    = new
        self.offset                 = offset
        self.partnerCoreContactId   = partnerCoreContactId
        self.partnerCoreUserId      = partnerCoreUserId
        self.threadIds              = threadIds
        
        self.typeCode               = typeCode
        self.uniqueId               = uniqueId ?? UUID().uuidString
    }
    
    
    public init(json: JSON) {
        self.count                  = json["count"].int
        self.creatorCoreUserId      = json["creatorCoreUserId"].int
        self.metadataCriteria       = json["metadataCriteria"].string
        self.threadName             = json["name"].string
        self.new                    = json["new"].bool
        self.offset                 = json["offset"].int
        self.partnerCoreContactId   = json["partnerCoreContactId"].int
        self.partnerCoreUserId      = json["partnerCoreUserId"].int
        self.threadIds              = json["threadIds"].arrayObject as? [Int]
        
        self.typeCode               = json["typeCode"].string
        self.uniqueId               = json["uniqueId"].string ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["count"]    = JSON(self.count ?? 50)
        content["offset"]   = JSON(self.offset ?? 0)
        if let name = self.threadName {
            let theThreadName = MakeCustomTextToSend(message: name).replaceSpaceEnterWithSpecificCharecters()
            content["name"] = JSON(theThreadName)
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
            let theMeta = MakeCustomTextToSend(message: metadataCriteria).replaceSpaceEnterWithSpecificCharecters()
            content["metadataCriteria"] = JSON(theMeta)
        }
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}



open class GetThreadsRequestModel: GetThreadsRequest {
    
}

