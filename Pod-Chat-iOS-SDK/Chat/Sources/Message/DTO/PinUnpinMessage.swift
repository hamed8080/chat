//
//  PinUnpinMessage.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/23/21.
//

open class PinUnpinMessage : Codable{
    
    public let messageId : Int
    public let notifyAll : Bool
    public let text      : String?
    public let sender    : Participant?
    public let time      : Int?
    
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
