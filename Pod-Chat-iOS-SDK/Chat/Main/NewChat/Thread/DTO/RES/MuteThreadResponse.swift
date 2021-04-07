//
//  MuteThreadResponse.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
public struct MuteThreadResponse : Decodable {
	public var threadId:Int? = nil
}

public typealias UnMuteThreadResponse = MuteThreadResponse
