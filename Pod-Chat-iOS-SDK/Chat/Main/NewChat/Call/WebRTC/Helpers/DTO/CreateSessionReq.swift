//
//  CreateSessionReq.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import Foundation

struct CreateSessionReq: Codable {
   
    var id            :String = "CREATE_SESSION"
    var brokerAddress :String
    var token         :String
    
    public init(id: String = "CREATE_SESSION", brokerAddress: String, token: String) {
        self.id            = id
        self.brokerAddress = brokerAddress
        self.token         = token
    }
    
}
