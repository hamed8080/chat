//
//  DeliverCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
struct DeliverCallRequest : Decodable {
    
    public let userId     : Int
    public let callStatus : CallStatus
    public let mute       : Bool
    public let video      : Bool
}
