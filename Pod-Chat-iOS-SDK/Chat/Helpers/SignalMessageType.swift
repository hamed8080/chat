//
//  SignalMessageType.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum SignalMessageType: Int {
    
    case IS_TYPING      = 1
    case RECORD_VOICE   = 2
    case UPLOAD_PICTURE = 3
    case UPLOAD_VIDEO   = 4
    case UPLOAD_SOUND   = 5
    case UPLOAD_FILE    = 6
    
    public func intValue() -> Int {
        switch self {
        case .IS_TYPING:        return 1
        case .RECORD_VOICE:     return 2
        case .UPLOAD_PICTURE:   return 3
        case .UPLOAD_VIDEO:     return 4
        case .UPLOAD_SOUND:     return 5
        case .UPLOAD_FILE:      return 6
        }
    }
    
}


