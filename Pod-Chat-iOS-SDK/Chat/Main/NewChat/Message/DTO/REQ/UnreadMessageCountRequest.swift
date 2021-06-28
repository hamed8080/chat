//
//  UnreadMessageCountRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/27/21.
//

import Foundation
public class UnreadMessageCountRequest: BaseRequest{
	
	let countMutedThreads:Bool
	
	public init (countMutedThreads:Bool = false,uniqueId:String? = nil , typeCode:String? = nil){
		self.countMutedThreads = countMutedThreads
        super.init(uniqueId: uniqueId, typeCode: typeCode)
	}
	
	private enum CodingKeys : String , CodingKey {
		case mute = "mute"
	}
	
	public override func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(countMutedThreads, forKey: .mute)
	}
}
