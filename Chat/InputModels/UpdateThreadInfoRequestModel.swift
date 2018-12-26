//
//  UpdateThreadInfoRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class UpdateThreadInfoRequestModel {
    
    public let subjectId:   Int?
    public let image:       String?
    public let description: String?
    public let title:       String?
    public let metadata:    JSON?
    public let typeCode:    String?
    
    public init(subjectId:     Int?,
                image:         String,
                description:   String?,
                title:         String,
                metadata:      JSON?,
                typeCode:      String?) {
        
        self.subjectId      = subjectId
        self.image          = image
        self.description    = description
        self.title          = title
        self.metadata       = metadata
        self.typeCode       = typeCode
    }
    
}

