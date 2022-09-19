//
//  IsThreadNamePublicRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation

public class IsThreadNamePublicRequest: BaseRequest {
	
	public let name:String
	
	public init(name:String, uniqueId: String? = nil){
		self.name = name
        super.init(uniqueId: uniqueId)
	}
	
	private enum CodingKeys:String,CodingKey{
		case name = "name"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try? container.encode(name, forKey: .name)
	}
}

