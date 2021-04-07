//
//  GetThreadParticipantsResponse.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class GetThreadParticipantsModel: ResponseModel, ResponseModelDelegates {
    
    public var contentCount:    Int = 0
    public var hasNext:         Bool = false
    public var nextOffset:      Int = 0
    public var participants:    [Participant] = []
    
    public init(messageContent: [JSON],
                contentCount:   Int,
                count:          Int,
                offset:         Int,
                hasError:       Bool,
                errorMessage:   String,
                errorCode:      Int) {
        
        let messageLength = messageContent.count
        self.contentCount = contentCount
        self.hasNext = false
        let x: Int = count + offset
        if (x < contentCount) && (messageLength > 0) {
            self.hasNext = true
        }
        self.nextOffset = offset + messageLength
        
        for item in messageContent {
            let participant = Participant(messageContent: item, threadId: nil)
            participants.append(participant)
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    public init(participantObjects: [Participant],
                contentCount:       Int,
                count:              Int,
                offset:             Int,
                hasError:           Bool,
                errorMessage:       String,
                errorCode:          Int) {
        
        let messageLength = participantObjects.count
        self.contentCount = contentCount
        self.hasNext = false
        let x: Int = count + offset
        if (x < contentCount) && (messageLength > 0) {
            self.hasNext = true
        }
        self.nextOffset = offset + messageLength
        
        for item in participantObjects {
            participants.append(item)
        }
        super.init(hasError: hasError, errorMessage: errorMessage, errorCode: errorCode)
    }
    
    
    public func returnDataAsJSON() -> JSON {
        var participantArr = [JSON]()
        for item in participants {
            participantArr.append(item.formatToJSON())
        }
        let result: JSON = ["contentCount": contentCount,
                            "hasNext":      hasNext,
                            "nextOffset":   nextOffset,
                            "participants": participantArr]
        
        let finalResult: JSON = ["result":          result,
                                 "hasError":        hasError,
                                 "errorMessage":    errorMessage,
                                 "errorCode":       errorCode]
        
        return finalResult
    }
}

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class GetThreadParticipantsResponse: GetThreadParticipantsModel {
    
}


