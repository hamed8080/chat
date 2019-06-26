//
//  DeleteMultipleMessagesRequestModel.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 4/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class DeleteMultipleMessagesRequestModel {
    
    public let deleteForAll:        JSON?
    public let subjectIds:          [Int]
    public let typeCode:            String?
    public let uniqueIds:           [String]?
    
    public init(deleteForAll:      JSON?,
                subjectIds:        [Int],
                typeCode:          String?,
                uniqueIds:         [String]?) {
        
        self.deleteForAll       = deleteForAll
        self.subjectIds         = subjectIds
        self.typeCode           = typeCode
        self.uniqueIds          = uniqueIds
    }
    
}
