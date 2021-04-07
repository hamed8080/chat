//
//  ForwardInfo.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class ForwardInfo : Codable {
    /*
     * + forwardInfo        ForwardInfo:
     *   - conversation         Conversation?
     *   - participant          Participant?
     */
    
    public var conversation:   Conversation?
    public var participant:    Participant?
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(messageContent: JSON) {
        
        if (messageContent["conversation"] != JSON.null) {
            self.conversation = Conversation(messageContent: messageContent["conversation"])
        }
        
        if (messageContent["participant"] != JSON.null) {
            self.participant = Participant(messageContent: messageContent["participant"], threadId: nil)
        }
        
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(conversation:  Conversation?,
                participant:   Participant?) {
        
        self.conversation   = conversation
        self.participant    = participant
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(theForwardInfo: ForwardInfo) {
        
        self.conversation   = theForwardInfo.conversation
        self.participant    = theForwardInfo.participant
    }
    
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public func formatDataToMakeForwardInfo() -> ForwardInfo {
        return self
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public func formatToJSON() -> JSON {
        let result: JSON = ["conversation":     conversation?.formatToJSON() ?? NSNull(),
                            "participant":      participant?.formatToJSON() ?? NSNull()]
        return result
    }
    
	
	private enum CodingKeys: String ,CodingKey{
		case conversation  = "conversation"
		case participant = "participant"
	}
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.conversation  = try container.decodeIfPresent(Conversation.self, forKey: .conversation)
		self.participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
	}
	
}
