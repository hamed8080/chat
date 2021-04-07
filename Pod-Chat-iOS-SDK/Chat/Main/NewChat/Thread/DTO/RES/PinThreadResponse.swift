//
//  PinThreadResponse.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/20/21.
//

import Foundation
public struct PinThreadResponse : Decodable {
	public var threadId:Int? = nil
}

public typealias UnPinThreadResponse = PinThreadResponse
