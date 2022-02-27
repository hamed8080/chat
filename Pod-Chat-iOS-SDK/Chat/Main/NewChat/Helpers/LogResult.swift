//
//  LogResult.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 5/12/21.
//

import Foundation
public struct LogResult{
    
    
    public var json     :String
    public var receive  :Bool
    
    public init(json: String, receive: Bool) {
        self.json       = json
        self.receive    = receive
    }
    
}
