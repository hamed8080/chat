//
//  CallState.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 10/4/21.
//

import Foundation
enum CallState:String{
	case Requested        = "Requested"
    case Created          = "Created"
	case Canceled         = "Canceled"
	case Started          = "Started"
	case Ended            = "Ended"
	case InitializeWEBRTC = "InitializeWEBRTC"
}
