//
//  RTCIceConnectionState.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 8/8/21.
//

import Foundation
import WebRTC
extension RTCIceConnectionState{
    var stringValue:String{
        switch self {
        case .checking     : return "checking"
        case .closed       : return "closed"
        case .completed    : return "completed"
        case .connected    : return "connected"
        case .count        : return "count"
        case .disconnected : return "disconnected"
        case .failed       : return "failed"
        case .new          : return "new"
        }
    }
}
