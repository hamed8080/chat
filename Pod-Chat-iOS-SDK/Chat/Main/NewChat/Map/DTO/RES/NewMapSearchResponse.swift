//
//  NewMapSearchResponse.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/1/21.
//

import Foundation

open class NewMapSearchResponse : Decodable{
	
	public var count:   Int
	public var items:   [NewMapItem]?
	
	private enum CodingKeys : String , CodingKey{
		case count       = "count"
		case items      = "items"
	}
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		count = (try container.decodeIfPresent(Int.self, forKey: .count)) ?? 0
		items = (try container.decodeIfPresent([NewMapItem].self, forKey: .items)) ?? nil
	}
}

open class NewMapItem : Codable{
	
	public let address    :     String?
	public let category   :    String?
	public let region     :      String?
	public let type       :        String?
	public let title      :       String?
	public var location   :    NewLocation?
	public var neighbourhood :String?
}

open class NewLocation : Codable{
	
	public let x: Double
	public let y: Double
}
