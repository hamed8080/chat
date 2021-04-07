//
//  RemoveParticipantResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 8/13/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class RemoveParticipantModel: ResponseModel, ResponseModelDelegates {
    
    public var contentCount:    Int             = 0
    public var participants:    [Participant]   = []
    
    public init(messageContent: JSON,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        self.contentCount = messageContent["contentCount"].int ?? 0
        
        if let result = messageContent["result"].array {
            for item in result {
                let tempContact = Participant(messageContent: item, threadId: nil)
                self.participants.append(tempContact)
            }
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(messageObjects: [Participant]?,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        if let result = messageObjects {
            self.contentCount = result.count
            for item in result {
                self.participants.append(item)
            }
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        var participantArr = [JSON]()
        for item in participants {
            participantArr.append(item.formatToJSON())
        }
        let result: JSON = ["participants": participantArr]
        
        let finalResult: JSON = ["result":          result,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode,
                                 "contentCount":    contentCount]
        
        return finalResult
    }
}


@available(*,deprecated , message:"Removed in 0.10.5.0 version")
open class RemoveParticipantResponse: RemoveParticipantModel {
    
}


