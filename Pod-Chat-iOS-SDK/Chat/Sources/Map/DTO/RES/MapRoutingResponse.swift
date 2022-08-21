//
//  MapRoutingResponse.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/1/21.
//

import Foundation
import Foundation

open class MapRoutingResponse:Decodable {
	
	public var routes:  [Route]? = nil
	
	private enum CodingKeys : String , CodingKey{
		case routes       = "routes"
	}
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.routes = try container.decodeIfPresent([Route].self, forKey: .routes) ?? nil
	}
}
