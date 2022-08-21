//
//  CreateThreadRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public class CreateThreadRequest: BaseRequest {
	
	public let description: String?
	public let image:       String?
	public let invitees:    [Invitee]?
	public let metadata:    String?
	public let title:       String
	public let type:        ThreadTypes?
	public let uniqueName:  String? //only for public thread
	
	public init(description:    String? = nil,
				image:          String? = nil,
				invitees:       [Invitee]? = nil,
				metadata:       String? = nil,
				title:          String,
				type:           ThreadTypes? = nil,
				uniqueName:     String? = nil,
                uniqueId:       String? = nil
                ) {
		
		self.description    = description
		self.image          = image
		self.invitees       = invitees
		self.metadata       = metadata
		self.title          = title
		self.type           = type
		self.uniqueName     = uniqueName
        super.init(uniqueId: uniqueId)
	}
	
	private enum CodingKeys: String ,CodingKey{
		case title       = "title"
		case image       = "image"
		case description = "description"
		case metadata    = "metadata"
		case uniqueName  = "uniqueName"
		case type        = "type"
		case invitees    = "invitees"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(title, forKey: .title)
		try container.encodeIfPresent(image, forKey: .image)
		try container.encodeIfPresent(description, forKey: .description)
		try container.encodeIfPresent(metadata, forKey: .metadata)
		try container.encodeIfPresent(uniqueName, forKey: .uniqueName)
		try container.encodeIfPresent(type, forKey: .type)
		try container.encodeIfPresent(invitees, forKey: .invitees)
	}
	
}
