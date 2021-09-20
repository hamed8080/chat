//
//  ClientDTO.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public struct ClientDTO :Codable {
    
    public let clientId      : String
    public let topicReceive  : String
    public let topicSend     : String
    public let brokerAddress : String
    public let desc          : String
    public let sendKey       : String
    public let video         : Bool
    public let mute          : Bool
    
    
    public init(clientId: String, topicReceive: String, topicSend: String, brokerAddress: String, desc: String, sendKey: String, video: Bool, mute: Bool) {
        self.clientId      = clientId
        self.topicReceive  = topicReceive
        self.topicSend     = topicSend
        self.brokerAddress = brokerAddress
        self.desc          = desc
        self.sendKey       = sendKey
        self.video         = video
        self.mute          = mute
    }
    
}
