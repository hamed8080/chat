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
     * + replyInfoVO        ReplyInfo:
     *   - participant          Participant?
     *   - repliedToMessage     String?
     *   - repliedToMessageId   Int?
     */
    
    var participant:        Participant?
    let repliedToMessage:   String?
    let repliedToMessageId: Int?
    
    init(messageContent: JSON) {
        self.repliedToMessageId     = messageContent["repliedToMessageId"].int
        self.repliedToMessage    = messageContent["repliedToMessage"].string
        
        if (messageContent["participant"] != JSON.null) {
            self.participant = Participant(messageContent: messageContent["participant"])
        }
        //        if let myParticipant = messageContent["participant"].array {
        //            self.participant = Participant(messageContent: myParticipant.first!)
        //        }
    }
    
    func formatDataToMakeReplyInfo() -> ReplyInfo {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["participant":          participant?.formatToJSON() ?? NSNull(),
                            "repliedToMessage":     repliedToMessage ?? NSNull(),
                            "repliedToMessageId":   repliedToMessageId ?? NSNull(),]
        return result
    }
    
}
