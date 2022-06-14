//
//  EditTagRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
public class EditTagRequest: BaseRequest {
	
	public var name  : String
    public var id    : Int
	
    public init(id:Int,tagName:String,uniqueId: String? = nil){
        self.id     = id
        self.name   = tagName
        super.init(uniqueId: uniqueId)
	}
    
    
	private enum CodingKeys:String , CodingKey{
		case name         = "name"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try? container.encode(name, forKey: .name)
	}
	
}
