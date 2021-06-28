//
//  ContactNotSeenDurationRespoonse.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/1/21.
//

import Foundation
open class ContactNotSeenDurationRespoonse:Decodable {
	
	public let notSeenDuration: [UserLastSeenDuration]
	
	public required init(from decoder: Decoder) throws {
		if let unkeyedContainer = try? decoder.singleValueContainer() , let dictionary = try? unkeyedContainer.decode([String:Int?].self){
			notSeenDuration = dictionary.map{UserLastSeenDuration(userId: Int($0) ?? 0, time: $1 ?? 0)}
		}else{
			notSeenDuration = []
		}
	}
}
