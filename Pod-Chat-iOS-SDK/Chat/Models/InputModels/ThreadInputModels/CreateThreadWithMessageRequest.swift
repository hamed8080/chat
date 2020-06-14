//
//  CreateThreadWithMessageRequest.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodAsyncSDK
import SwiftyJSON

open class CreateThreadWithMessageRequest: RequestModelDelegates {
    
    public var createThreadInput:   CreateThreadRequest
    public var sendMessageInput:    CreateThreadMessageInput?
    
    public init(createThreadInput:  CreateThreadRequest,
                sendMessageInput:   CreateThreadMessageInput?) {
        
        self.createThreadInput  = createThreadInput
        self.sendMessageInput   = sendMessageInput
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
//        content["title"] = JSON(self.createThreadInput.title)
        content["title"] = JSON(MakeCustomTextToSend(message: self.createThreadInput.title).replaceSpaceEnterWithSpecificCharecters())
        var inviteees = [JSON]()
        for item in self.createThreadInput.invitees {
            inviteees.append(item.formatToJSON())
        }
        content["invitees"] = JSON(inviteees)
        if let description = self.createThreadInput.description {
            let theDescription = MakeCustomTextToSend(message: description).replaceSpaceEnterWithSpecificCharecters()
            content["description"] = JSON(theDescription)
        }
        if let image = self.createThreadInput.image {
            content["image"] = JSON(image)
        }
        if let metadata2 = self.createThreadInput.metadata {
            let theMeta = MakeCustomTextToSend(message: metadata2).replaceSpaceEnterWithSpecificCharecters()
            content["metadata"] = JSON(theMeta)
        }
        if let uniqueName_ = self.createThreadInput.uniqueName {
            content["uniqueName"] = JSON(uniqueName_)
        }
        content["type"] = JSON(self.createThreadInput.type?.intValue() ?? 0)
        
        if let message_ = sendMessageInput {
            content["message"] = message_.convertContentToJSON()
        }
        
        return content
    }
    
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}


/// MARK: -  this class will be deprecate (use this class instead: 'ClearHistoryRequest')
open class CreateThreadWithMessageRequestModel: CreateThreadWithMessageRequest {
    
}

