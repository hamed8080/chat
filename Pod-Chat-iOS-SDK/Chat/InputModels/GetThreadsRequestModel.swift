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
    
    public let count:               Int?
    public let coreUserId:          Int?
    public let metadataCriteria:    JSON?
    public let name:                String?
    public let new:                 Bool?
    public let offset:              Int?
    public let threadIds:           [Int]?
    public let typeCode:            String?
    
    public init(count:             Int?,
                coreUserId:        Int?,
                metadataCriteria:  JSON?,
                name:              String?,
                new:               Bool?,
                offset:            Int?,
                threadIds:         [Int]?,
                typeCode:          String?) {
        
        self.count              = count
        self.coreUserId     = coreUserId
        self.metadataCriteria   = metadataCriteria
        self.name               = name
        self.new                = new
        self.offset             = offset
        self.threadIds          = threadIds
        self.typeCode           = typeCode
    }
    
}

