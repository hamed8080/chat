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
     * + forwardInfo        ForwardInfo:
     *   - conversation         Conversation?
     *   - participant          Participant?
     */
    
    var conversation:   Conversation?
    var participant:    Participant?
    
    init(messageContent: JSON) {
        
        if (messageContent["conversation"] != JSON.null) {
            self.conversation = Conversation(messageContent: messageContent["conversation"])
        }
        
        if (messageContent["participant"] != JSON.null) {
            self.participant = Participant(messageContent: messageContent["participant"])
        }
        
        //        if let myConversation = messageContent["conversation"].array {
        //            self.conversation = Conversation(messageContent: myConversation.first!)
        //        }
        //        if let myParticipant = messageContent["participant"].array {
        //            self.participant = Participant(messageContent: myParticipant.first!)
        //        }
        
    }
    
    func formatDataToMakeForwardInfo() -> ForwardInfo {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["conversation":     conversation?.formatToJSON() ?? NSNull(),
                            "participant":      participant?.formatToJSON() ?? NSNull()]
        return result
    }
    
}
