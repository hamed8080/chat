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

open class ReplyInfo {
    /*
     * + replyInfoVO        ReplyInfo:
     *  - deleted:             Bool?            // Delete state of Replied Message
     *  - repliedToMessageId:  Int?             // Id of Replied Message
     *  - message:             String?          // Content of Replied Message
     *  - messageType:         Int?             // Type of Replied Message
     *  - metadata:            String?          // metadata of Replied Message
     *  - systemMetadata:      String?          // systemMetadata of Replied Message
     *  - participant          Participant?     // Sender of Replied Message
     *  - repliedToMessage     String?
     *  - repliedToMessageId   Int?
     */
    
    public var deleted:             Bool?
    public var message:             String?
    public var messageType:         Int?
    public var metadata:            String?
    public var repliedToMessageId:  Int?
    public var systemMetadata:      String?
    
    public var participant:        Participant?
    //    public let repliedToMessage:    String?
    
    init(messageContent: JSON) {
        
        self.deleted            = messageContent["deleted"].bool
        self.message            = messageContent["message"].string
        self.messageType        = messageContent["messageType"].int
        self.metadata           = messageContent["metadata"].string
        self.repliedToMessageId = messageContent["repliedToMessageId"].int
        self.systemMetadata     = messageContent["systemMetadata"].string
        
        if (messageContent["participant"] != JSON.null) {
            self.participant = Participant(messageContent: messageContent["participant"])
        }
        
    }
    
    func formatDataToMakeReplyInfo() -> ReplyInfo {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["participant":          participant?.formatToJSON() ?? NSNull(),
                            "deleted":              deleted ?? NSNull(),
                            "message":              message ?? NSNull(),
                            "messageType":          messageType ?? NSNull(),
                            "metadata":             metadata ?? NSNull(),
                            "repliedToMessageId":   repliedToMessageId ?? NSNull(),
                            "systemMetadata":       systemMetadata ?? NSNull()]
        return result
    }
    
}
