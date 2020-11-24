//
//  CALL_TYPE.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation


public enum CALL_TYPE {
    
    case VOICE_CALL
    case VIDEO_CALL
    
    func intValue() -> Int {
        switch self {
        case .VOICE_CALL:   return 0
        case .VIDEO_CALL:   return 1
        }
    }
    
}
