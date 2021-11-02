//
//  RTCSignalingState.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 8/8/21.
//

import Foundation
import WebRTC
extension RTCSignalingState{
    var stringValue:String{
        switch self {
        case .closed             : return "closed"
        case .haveLocalOffer     : return "haveLocalOffer"
        case .haveLocalPrAnswer  : return "haveLocalPrAnswer"
        case .haveRemoteOffer    : return "haveRemoteOffer"
        case .haveRemotePrAnswer : return "haveRemotePrAnswer"
        case .stable             : return "stable"
        }
    }
}
