//
//  ReplyInfo.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      ReplyInfo        (formatDataToMakeReplyInfo)
//#######################################################################################

class ReplyInfo {
    /*
     * + replyInfoVO                  {object : replyInfoVO}
     *   - participant                {object : ParticipantVO}
     *   - repliedToMessageId         {long}
     *   - repliedToMessage           {string}
     */
    
    let repliedToMessageId: Int?
    let repliedToMessage:   String?
    var participant:        Participant?
    
    init(messageContent: JSON) {
        self.repliedToMessageId     = messageContent["repliedToMessageId"].int
        self.repliedToMessage    = messageContent["repliedToMessage"].string
        
        if let myParticipant = messageContent["participant"].array {
            self.participant = Participant(messageContent: myParticipant.first!)
        }
    }
    
    func formatDataToMakeReplyInfo() -> ReplyInfo {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["repliedToMessageId":   repliedToMessageId ?? NSNull(),
                            "repliedToMessage":     repliedToMessage ?? NSNull(),
                            "participant":          participant?.formatToJSON() ?? NSNull()]
        return result
    }
    
}
