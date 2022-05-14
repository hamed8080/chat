//
//  ForwardInfo.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation

open class ForwardInfo : Codable {
    
    public var conversation:   Conversation?
    public var participant:    Participant?
	
	private enum CodingKeys: String ,CodingKey{
		case conversation  = "conversation"
		case participant = "participant"
	}
    
    public init(conversation: Conversation?, participant: Participant?) {
        self.conversation   = conversation
        self.participant    = participant
    }
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.conversation  = try container.decodeIfPresent(Conversation.self, forKey: .conversation)
		self.participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
	}
	
}
