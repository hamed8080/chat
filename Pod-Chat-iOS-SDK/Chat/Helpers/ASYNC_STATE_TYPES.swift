//
//  asyncStateTypes.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum ASYNC_STATE_TYPES {
    
    case CONNECTING
    case CONNECTED
    case CLOSING
    case CLOSED
    
    public func stringValue() -> String {
        switch self {
        case .CONNECTING:    return "CONNECTING"
        case .CONNECTED:     return "CONNECTED"
        case .CLOSING:       return "CLOSING"
        case .CLOSED:        return "CLOSED"
        }
    }
    
    public func intValue() -> Int {
        switch self {
        case .CONNECTING:    return 0
        case .CONNECTED:     return 1
        case .CLOSING:       return 2
        case .CLOSED:        return 3
        }
    }
    
}


