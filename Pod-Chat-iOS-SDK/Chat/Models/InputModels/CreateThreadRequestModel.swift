//
//  CreateThreadRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class CreateThreadRequestModel {
    
    public let description: String?
    public let image:       String?
    public let invitees:    [Invitee]
    public let metadata:    String?
    public let title:       String
    public let type:        ThreadTypes?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(description:    String?,
                image:          String?,
                invitees:       [Invitee],
                metadata:       String?,
                title:          String,
                type:           ThreadTypes?,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.description    = description
        self.image          = image
        self.invitees       = invitees
        self.metadata       = metadata
        self.title          = title
        self.type           = type
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["title"] = JSON(self.title)
        var inviteees = [JSON]()
        for item in self.invitees {
            inviteees.append(item.formatToJSON())
        }
        content["invitees"] = JSON(inviteees)
        if let description = self.description {
            content["description"] = JSON(description)
        }
        if let image = self.image {
            content["image"] = JSON(image)
        }
        if let metadata2 = self.metadata {
            content["metadata"] = JSON(metadata2)
        }
        if let typeCode_ = self.typeCode {
            content["typeCode"] = JSON(typeCode_)
        }
        content["type"] = JSON(self.type?.intValue() ?? 0)
        content["uniqueId"] = JSON(self.uniqueId)
        
        return content
    }
    
}

