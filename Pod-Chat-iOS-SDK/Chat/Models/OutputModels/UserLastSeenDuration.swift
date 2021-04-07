//
//  UserLastSeenDuration.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 2/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

@available(*,deprecated , message:"Removed in XX.XX.XX version")
open class UserLastSeenDuration :Codable{
    
    public var userId: Int
    public var time:   Int
    
    init(userId: Int, time: Int) {
        self.userId = userId
        self.time   = time
    }
    
    public func convertDataToJSON() -> JSON {
        var result: JSON = [:]
        result["userId"]    = JSON(userId)
        result["time"]      = JSON(time)
        return result
    }
    
}

