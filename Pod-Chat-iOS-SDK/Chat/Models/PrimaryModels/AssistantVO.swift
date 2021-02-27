//
//  AssistantVO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/9/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class AssistantVO {
    
    public var contactType: String?
    public var assistant:   Invitee?
    public var participant: Participant?
    public var roleTypes:   [Roles]?
    
    
    public init(messageContent: JSON) {
        self.contactType    = messageContent["contactType"].string
        if messageContent["assistant"].exists() {
            self.assistant = Invitee(messageContent: messageContent["assistant"] )
        }
        if messageContent["participantVO"].exists() {
            self.participant = Participant(messageContent: messageContent["participantVO"], threadId: nil)
        }
        if let rolesJSON = messageContent["roleTypes"].arrayObject as? [String] {
            var tempRoles = [Roles]()
            for item in rolesJSON {
                if let role = Roles(rawValue: item) {
                    tempRoles.append(role)
                }
            }
            self.roleTypes = tempRoles
        }
    }
    
    public init(contactType:    String?,
                assistant:      Invitee,
                participant:    Participant?,
                roleTypes:      [Roles]?) {
        self.contactType    = contactType
        self.assistant      = assistant
        self.participant    = participant
        self.roleTypes      = roleTypes
    }
    
    public init(theAssistant: AssistantVO) {
        self.contactType    = theAssistant.contactType
        self.assistant      = theAssistant.assistant
        self.participant    = theAssistant.participant
        self.roleTypes      = theAssistant.roleTypes
    }
    
    public func formatToJSON() -> JSON {
        
        var roles: [String]?
        if let myRoleTypes = roleTypes {
            roles = []
            for item in myRoleTypes {
                roles!.append(item.stringValue())
            }
        }
        
        let result: JSON = ["contactType":  contactType ?? NSNull(),
                            "assistant":    assistant?.formatToJSON() ?? NSNull(),
                            "participant":  participant?.formatToJSON() ?? NSNull(),
                            "roleTypes":    roles ?? NSNull()]
        return result
    }
    
}
