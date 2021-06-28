//
//  CreateThreadRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodAsyncSDK
import SwiftyJSON

@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class CreateThreadRequest: RequestModelDelegates {
    
    public let description: String?
    public let image:       String?
    public let invitees:    [Invitee]
    public let metadata:    String?
    public let title:       String
    public let type:        ThreadTypes?
    public let uniqueName:  String?
    
    public let typeCode:    String?
    public let uniqueId:    String
    
    public init(description:    String?,
                image:          String?,
                invitees:       [Invitee],
                metadata:       String?,
                title:          String,
                type:           ThreadTypes?,
                uniqueName:     String?,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.description    = description
        self.image          = image
        self.invitees       = invitees
        self.metadata       = metadata
        self.title          = title
        self.type           = type
        self.uniqueName     = uniqueName
        
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId ?? UUID().uuidString
    }
    
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["title"] = JSON(MakeCustomTextToSend(message: self.title).replaceSpaceEnterWithSpecificCharecters())
        var inviteees = [JSON]()
        for item in self.invitees {
            inviteees.append(item.formatToJSON())
        }
        content["invitees"] = JSON(inviteees)
        if let description = self.description {
            let theDescription = MakeCustomTextToSend(message: description).replaceSpaceEnterWithSpecificCharecters()
            content["description"] = JSON(theDescription)
        }
        if let image = self.image {
            content["image"] = JSON(image)
        }
        if let metadata2 = self.metadata {
            let theMeta = MakeCustomTextToSend(message: metadata2).replaceSpaceEnterWithSpecificCharecters()
            content["metadata"] = JSON(theMeta)
        }
        if let uniqueName_ = self.uniqueName {
            content["uniqueName"] = JSON(uniqueName_)
        }
        if let typeCode_ = self.typeCode {
            content["typeCode"] = JSON(typeCode_)
        }
        content["type"] = JSON(self.type?.intValue() ?? 0)
        content["uniqueId"] = JSON(self.uniqueId)
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}


/// MARK: -  this class will be deprecate (use this class instead: 'CreateThreadRequest')
@available(*,deprecated , message:"Removed in 0.10.5.0 version.")
open class CreateThreadRequestModel: CreateThreadRequest {
    
}

