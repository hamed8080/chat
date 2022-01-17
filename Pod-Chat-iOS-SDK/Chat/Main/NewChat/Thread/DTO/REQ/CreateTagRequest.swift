//
//  CreateTagRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
public class CreateTagRequest: BaseRequest {
	
	public var name  : String
	
	public init(tagName:String,uniqueId: String? = nil, typeCode: String? = nil){
        self.name   = tagName
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
    
    
	private enum CodingKeys:String , CodingKey{
		case name         = "name"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try? container.encode(name, forKey: .name)
	}
	
}
