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
    
    public let count:                   Int?
    public let creatorCoreUserId:       Int?
    public let metadataCriteria:        JSON?
    public let name:                    String?
    public let new:                     Bool?
    public let offset:                  Int?
    public let partnerCoreContactId:    Int?
    public let partnerCoreUserId:       Int?
    public let threadIds:               [Int]?
    public let typeCode:                String?
    public let uniqueId:                String?
    
    public init(count:                  Int?,
                creatorCoreUserId:      Int?,
                metadataCriteria:       JSON?,
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
        self.name                   = name
        self.new                    = new
        self.offset                 = offset
        self.partnerCoreContactId   = partnerCoreContactId
        self.partnerCoreUserId      = partnerCoreUserId
        self.threadIds              = threadIds
        self.typeCode               = typeCode
        self.uniqueId               = uniqueId
    }
    
}


class GetAllThreadsRequestModel {
    
    public let summary:     Bool
    public let typeCode:    String?
    
    init(summary:   Bool,
         typeCode:  String?) {
        self.summary    = summary
        self.typeCode   = typeCode
    }
    
}

