//
//  PinUnpinMessage.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/29/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON


open class PinUnpinMessage {
    
    public let messageId:   Int
    public let notifyAll:   Bool
    public let text:        String?

    public init(messageId:  Int,
                notifyAll:  Bool,
                text:       String?) {

        self.messageId  = messageId
        self.notifyAll  = notifyAll
        self.text       = text
    }
    
    public init(pinUnpinContent: JSON) {

        self.messageId  = pinUnpinContent["messageId"].intValue
        self.notifyAll  = pinUnpinContent["notifyAll"].boolValue
        self.text       = pinUnpinContent["text"].string
    }
    
    func formatToJSON() -> JSON {
        var content: JSON = [:]
        content["messageId"] = JSON(messageId)
        content["notifyAll"] = JSON(notifyAll)
        if let text_ = text {
            content["text"] = JSON(text_)
        }
        return content
    }
    
}
