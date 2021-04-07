//
//  NewDeleteMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public class NewDeleteMessageRequest: BaseRequest {
	
	public let deleteForAll:    Bool
	public let messageId:       Int
	
	
	public init(deleteForAll:   Bool? = false,
				messageId:      Int,
				typeCode:       String? = nil,
				uniqueId:       String? = nil) {
		
		self.deleteForAll   = deleteForAll ?? false
		self.messageId      = messageId
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
	private enum CodingKeys : String , CodingKey{
		case deleteForAll = "deleteForAll"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(deleteForAll, forKey: .deleteForAll)
	}
}
