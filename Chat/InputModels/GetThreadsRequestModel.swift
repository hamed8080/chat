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
    public let offset:              Int?
    public let name:                String?
    public let new:                 Bool?
    public let threadIds:           [Int]?
    public let typeCode:            String?
    public let metadataCriteria:    JSON?
    
    public init(count:             Int?,
                offset:            Int?,
                name:              String?,
                new:               Bool?,
                threadIds:         [Int]?,
                typeCode:          String?,
                metadataCriteria:  JSON?) {
        
        self.count              = count
        self.offset             = offset
        self.name               = name
        self.new                = new
        self.threadIds          = threadIds
        self.typeCode           = typeCode
        self.metadataCriteria   = metadataCriteria
    }
    
}

