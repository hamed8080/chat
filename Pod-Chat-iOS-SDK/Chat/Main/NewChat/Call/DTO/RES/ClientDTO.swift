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
}
