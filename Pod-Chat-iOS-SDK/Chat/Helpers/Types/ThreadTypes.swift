//
//  ThreadTypes.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

public enum ThreadTypes : Int , Encodable ,CaseIterable {
    
    case NORMAL = 0                  // "NORMAL"
    case OWNER_GROUP  = 1          // "OWNER_GROUP"
    case PUBLIC_GROUP   = 2         // "PUBLIC_GROUP"
    case CHANNEL_GROUP   = 4       // "CHANNEL_GROUP"
    case CHANNEL   = 8             // "CHANNEL"
    case NOTIFICATION_CHANNEL = 16   // "NOTIFICATION_CHANNEL"
    
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func stringValue() -> String {
        switch self {
        case .NORMAL:               return "NORMAL"
        case .OWNER_GROUP:          return "OWNER_GROUP"
        case .PUBLIC_GROUP:         return "PUBLIC_GROUP"
        case .CHANNEL_GROUP:        return "CHANNEL_GROUP"
        case .CHANNEL:              return "CHANNEL"
        case .NOTIFICATION_CHANNEL: return "NOTIFICATION_CHANNEL"
        }
    }
	
	@available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func intValue() -> Int {
        switch self {
        case .NORMAL:               return 0
        case .OWNER_GROUP:          return 1
        case .PUBLIC_GROUP:         return 2
        case .CHANNEL_GROUP:        return 4
        case .CHANNEL:              return 8
        case .NOTIFICATION_CHANNEL: return 16
        }
    }
    
}


