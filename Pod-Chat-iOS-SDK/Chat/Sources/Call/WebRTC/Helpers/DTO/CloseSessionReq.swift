//
//  CloseSessionReq.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import Foundation

struct CloseSessionReq: Codable {
   
    var id            :String = "CLOSE"
    var token         :String
    var uniqueId:String      = UUID().uuidString
    
    public init(token: String) {
        self.token         = token
    }
    
}
