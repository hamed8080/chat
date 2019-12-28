//
//  ThreadTypes.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum ThreadTypes: String {
    
    case NORMAL                 = "NORMAL"
    case OWNER_GROUP            = "OWNER_GROUP"
    case PUBLIC_GROUP           = "PUBLIC_GROUP"
    case CHANNEL_GROUP          = "CHANNEL_GROUP"
    case CHANNEL                = "CHANNEL"
    case NOTIFICATION_CHANNEL   = "NOTIFICATION_CHANNEL"
    
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
    
}


