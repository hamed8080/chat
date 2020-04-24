//
//  SignalMessageType.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/4/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum SignalMessageType {
    
    case IS_TYPING
    case RECORD_VOICE
    case UPLOAD_PICTURE
    case UPLOAD_VIDEO
    case UPLOAD_SOUND
    case UPLOAD_FILE    
    
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


