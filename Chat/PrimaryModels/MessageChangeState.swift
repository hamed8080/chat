//
//  MessageChangeState.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


//#######################################################################################
//#############################      MessageChangeState        (formatDataToMakeMessageChangeState)
//#######################################################################################

class MessageChangeState {
    /*
     * + MessageChangeStateVO   MessageChangeState:
     *    - messageId               Int?
     *    - senderId                Int?
     *    - threadId                Int?
     */
    
    let messageId:  Int?
    let senderId:   Int?
    let threadId:   Int?
    
    init(messageContent: JSON) {
        self.messageId  = messageContent["messageId"].int
        self.senderId   = messageContent["senderId"].int
        self.threadId   = messageContent["threadId"].int
    }
    
    func formatDataToMakeMessageChangeState() -> MessageChangeState {
        return self
    }
    
    func formatToJSON() -> JSON {
        let result: JSON = ["messageId":        messageId ?? NSNull(),
                            "senderId":         senderId ?? NSNull(),
                            "threadId":         threadId ?? NSNull()]
        return result
    }
    
}
