//
//  UpdateChatProfile.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation

public class UpdateChatProfile: BaseRequest {
	
	public let bio:         String?
	public let metadata:    String?
	
	public init(bio: String?, metadata:String? = nil,uniqueId:String? = nil , typeCode:String? = nil) {
		
		self.bio        = bio
		self.metadata   = metadata
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
	private enum CodingKeys : String , CodingKey{
        case bio      = "bio"
		case metadata = "metadata"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(bio, forKey: .bio)
		try container.encodeIfPresent(metadata, forKey: .metadata)
	}
}
