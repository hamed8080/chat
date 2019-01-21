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
    
    public let description: String?
    public let image:       String?
    public let metadata:    JSON?
    public let subjectId:   Int?
    public let title:       String?
    public let typeCode:    String?
    
    public init(description:   String?,
                image:         String,
                metadata:      JSON?,
                subjectId:     Int?,
                title:         String,
                typeCode:      String?) {
        
        self.description    = description
        self.image          = image
        self.metadata       = metadata
        self.subjectId      = subjectId
        self.title          = title
        self.typeCode       = typeCode
    }
    
}

