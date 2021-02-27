//
//  AssistantAction.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/9/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class AssistantAction {
    
    public var actionName:  String?
    public var actionTime:  UInt?
    public var actionType:  Int?
    public var participant: Participant?
    
    
    public init(messageContent: JSON) {
        self.actionName    = messageContent["actionName"].string
        self.actionTime    = messageContent["actionTime"].uInt
        self.actionType    = messageContent["actionType"].int
        
        if messageContent["participantVO"].exists() {
            self.participant = Participant(messageContent: messageContent["participantVO"], threadId: nil)
        }
    }
    
    public init(actionName:     String?,
                actionTime:     UInt?,
                actionType:     Int?,
                participant:    Participant?) {
        self.actionName     = actionName
        self.actionTime     = actionTime
        self.actionType     = actionType
        self.participant    = participant
    }
    
    public init(theAssistantAction: AssistantAction) {
        self.actionName     = theAssistantAction.actionName
        self.actionTime     = theAssistantAction.actionTime
        self.actionType     = theAssistantAction.actionType
        self.participant    = theAssistantAction.participant
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["actionName":   actionName ?? NSNull(),
                            "actionTime":   actionTime ?? NSNull(),
                            "actionType":   actionType ?? NSNull(),
                            "Participant":  participant?.formatToJSON() ?? NSNull()]
        return result
    }
    
}
