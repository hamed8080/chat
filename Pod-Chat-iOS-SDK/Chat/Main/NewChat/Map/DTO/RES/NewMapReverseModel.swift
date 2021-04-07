//
//  NewMapReverseModel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/1/21.
//

import Foundation
open class NewMapReverseModel: ResponseModel {
	
	public var reverse: NewMapReverse? = nil
	
	private enum CodingKeys : String , CodingKey{
		case hasError     = "hasError"
		case message      = "message"
		case errorCode    = "errorCode"
		case reverse      = "reverse"
	}
	
	public required init(from decoder: Decoder) throws {
		let container     = try decoder.container(keyedBy: CodingKeys.self)
		reverse           = try container.decodeIfPresent(NewMapReverse.self, forKey: .reverse)
		let errorCode     = try container.decodeIfPresent(Int.self, forKey: .errorCode) ?? 0
		let hasError      = try container.decodeIfPresent(Bool.self, forKey: .hasError) ?? false
		let message       = try container.decodeIfPresent(String.self, forKey: .message) ?? ""
		super.init(hasError: hasError, errorMessage: message, errorCode: errorCode)
	}
	
}


