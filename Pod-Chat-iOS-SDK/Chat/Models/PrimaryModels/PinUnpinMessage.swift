//
//  PinUnpinMessage.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/29/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import SwiftyJSON

open class PinUnpinMessage : Codable{
    
    public let messageId:   Int
    public let notifyAll:   Bool
    public let text:        String?
    public let sender:      Participant?
    public let time:        Int?
    
    public init(messageId:  Int,
                notifyAll:  Bool,
                text:       String?,
                sender:     Participant?,
                time:       Int?) {
        
        self.messageId  = messageId
        self.notifyAll  = notifyAll
        self.text       = text
        self.sender     = sender
        self.time       = time
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(pinUnpinContent: JSON) {
        self.messageId  = pinUnpinContent["messageId"].intValue
        self.notifyAll  = pinUnpinContent["notifyAll"].boolValue
        self.text       = pinUnpinContent["text"].string
        self.sender     = Participant(messageContent: pinUnpinContent["sender"], threadId: nil)
        self.time       = pinUnpinContent["time"].int
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    func formatToJSON() -> JSON {
        var content: JSON = [:]
        content["messageId"] = JSON(messageId)
        content["notifyAll"] = JSON(notifyAll)
        if let text_ = text {
            content["text"] = JSON(text_)
        }
        if let sender_ = sender {
            content["sender"] = sender_.formatToJSON()
        }
        if let time_ = time {
            content["time"] = JSON(time_)
        }
        return content
    }

	private enum CodingKeys: String ,CodingKey{
        case messageId = "messageId"
		case notifyAll = "notifyAll"
        case text      = "text"
        case sender    = "sender"
        case time      = "time"
	}
	
	public required init(from decoder: Decoder) throws {
        let container  = try decoder.container(keyedBy : CodingKeys.self)
        self.messageId = try container.decode(Int.self, forKey: .messageId)
        self.notifyAll = try container.decodeIfPresent(Bool.self, forKey : .notifyAll) ?? false
        self.text      = try container.decodeIfPresent(String.self, forKey : .text)
        self.sender    = try container.decodeIfPresent(Participant.self, forKey : .sender)
        self.time      = try container.decodeIfPresent(Int.self, forKey : .time)
	}
}
