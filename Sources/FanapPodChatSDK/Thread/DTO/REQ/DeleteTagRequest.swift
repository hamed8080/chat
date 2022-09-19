//
//  DeleteTagRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/22/21.
//

import Foundation
public class DeleteTagRequest: BaseRequest {
	
    public var id    : Int
	
    public init(id:Int, uniqueId: String? = nil){
        self.id     = id
        super.init(uniqueId: uniqueId)
	}
}
