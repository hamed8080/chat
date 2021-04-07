//
//  AsyncStateType.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 1/30/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum AsyncStateType {
    
    case CONNECTING     // The connection is not open yet.
    case CONNECTED      // The connection is open and ready to communicate.
    case CLOSING        // The connection is in the process of closing.
    case CLOSED         // The connection is closed or couldn't be opened.
    
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

