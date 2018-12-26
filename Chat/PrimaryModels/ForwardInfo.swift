//
//  ForwardInfo.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      ForwardInfo        (formatDataToMakeForwardInfo)
//#######################################################################################

open class ForwardInfo {
    /*
     * + forwardInfo        ForwardInfo:
     *   - conversation         Conversation?
     *   - participant          Participant?
     */
    
    public var conversation:   Conversation?
    public var participant:    Participant?
    
    public init(messageContent: JSON) {
        
        if (messageContent["conversation"] != JSON.null) {
            self.conversation = Conversation(messageContent: messageContent["conversation"])
        }
        
        if (messageContent["participant"] != JSON.null) {
            self.participant = Participant(messageContent: messageContent["participant"])
        }
        
    }
    
    public init(conversation:  Conversation?,
                participant:   Participant?) {
        
        self.conversation   = conversation
        self.participant    = participant
    }
    
    public init(theForwardInfo: ForwardInfo) {
        
        self.conversation   = theForwardInfo.conversation
        self.participant    = theForwardInfo.participant
    }
    
    
    public func formatDataToMakeForwardInfo() -> ForwardInfo {
        return self
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["conversation":     conversation?.formatToJSON() ?? NSNull(),
                            "participant":      participant?.formatToJSON() ?? NSNull()]
        return result
    }
    
}
