//
//  Profile.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 11/20/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class Profile : Codable {
    
    public var bio:         String?
    public var metadata:    String?
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(messageContent: JSON) {
        self.bio        = messageContent["bio"].string
        self.metadata   = messageContent["metadata"].string
    }
    
    public init(bio:        String?,
                metadata:   String?) {
        self.bio        = bio
        self.metadata   = metadata
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(theProfile: Profile) {
        self.bio        = theProfile.bio
        self.metadata   = theProfile.metadata
    }
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public func formatToJSON() -> JSON {
        let result: JSON = ["bio":      bio ?? NSNull(),
                            "metadata": metadata ?? NSNull()]
        return result
    }
    
	private enum CodingKeys: String ,CodingKey{
		case bio  = "bio"
		case metadata = "metadata"
	}
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.bio  = try container.decodeIfPresent(String.self, forKey: .bio)
		self.metadata  = try container.decodeIfPresent(String.self, forKey: .metadata)
	}
}
