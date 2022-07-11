//
//  BaseRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
public  class BaseRequest: Encodable{
	
	public var uniqueId:String
	public var isAutoGenratedUniqueId = false
	

	public init(uniqueId:String? = nil) {
		isAutoGenratedUniqueId = uniqueId == nil
		self.uniqueId = uniqueId ?? UUID().uuidString
	}
	
	public func encode(to encoder: Encoder) throws {
		//this empty method must prevent encode values it's send through Chat.sendToAsync and fill uniqueId automatically
	}
}
