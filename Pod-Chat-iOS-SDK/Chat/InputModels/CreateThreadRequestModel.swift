//
//  CreateThreadRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class CreateThreadRequestModel {
    
    public let description:     String?
    public let image:           String?
    public let invitees:        [Invitee]
    public let metadata:        String?
    public let title:           String
    public let type:            ThreadTypes?
    public let requestUniqueId: String?
    
    public init(description:        String?,
                image:              String?,
                invitees:           [Invitee],
                metadata:           String?,
                title:              String,
                type:               ThreadTypes?,
                requestUniqueId:    String?) {
        
        self.description        = description
        self.image              = image
        self.invitees           = invitees
        self.metadata           = metadata
        self.title              = title
        self.type               = type
        self.requestUniqueId    = requestUniqueId
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["title"] = JSON(self.title)
        var inviteees = [JSON]()
        for item in self.invitees {
            inviteees.append(item.formatToJSON())
        }
        content["invitees"] = JSON(inviteees)
        if let image = self.image {
            content["image"] = JSON(image)
        }
        if let metaData = self.metadata {
            content["metadata"] = JSON(metaData)
        }
        if let description = self.description {
            content["description"] = JSON(description)
        }
        if let type = self.type {
            var theType: Int = 0
            switch type {
            case    ThreadTypes.NORMAL:        theType = 0
            case    ThreadTypes.OWNER_GROUP:   theType = 1
            case    ThreadTypes.PUBLIC_GROUP:  theType = 2
            case    ThreadTypes.CHANNEL_GROUP: theType = 4
            case    ThreadTypes.CHANNEL:       theType = 8
            default: break
            }
            content["type"] = JSON(theType)
        }
        
        return content
    }
    
}

