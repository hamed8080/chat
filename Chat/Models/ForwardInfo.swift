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

class ForwardInfo {
    /*
     * + forwardInfo                  {object : forwardInfoVO}
     *   - participant                {object : ParticipantVO}
     *   - conversation               {object : ConversationSummary}
     */
    
    var participant:    Participant?
    var conversation:   Conversation?
    
    init(messageContent: JSON) {
        if let myParticipant = messageContent["participant"].array {
            self.participant = Participant(messageContent: myParticipant.first!)
        }
        if let myConversation = messageContent["conversation"].array {
            self.conversation = Conversation(messageContent: myConversation.first!)
        }
    }
    
    func formatDataToMakeForwardInfo() -> ForwardInfo {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["participant":      participant?.formatToJSON() ?? NSNull(),
                            "conversation":     conversation?.formatToJSON() ?? NSNull()]
        return result
    }
    
}
