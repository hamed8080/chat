//
//  Profile.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//
import Foundation

open class Profile : Codable {
    
    public var bio      : String?
    public var metadata : String?
    
    public init(bio: String?, metadata: String?) {
        self.bio        = bio
        self.metadata   = metadata
    }
    
	private enum CodingKeys: String ,CodingKey{
		case bio      = "bio"
		case metadata = "metadata"
	}
    
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.bio  = try container.decodeIfPresent(String.self, forKey: .bio)
		self.metadata  = try container.decodeIfPresent(String.self, forKey: .metadata)
	}
}
