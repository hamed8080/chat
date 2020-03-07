//
//  MESSAGE_TYPES.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/6/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

public enum MESSAGE_TYPE {
    
    case text
    case voice
    case picture
    case video
    case sound
    case file
    
    public func returnIntValue() -> Int {
        switch self {
        case .text:     return 1
        case .voice:    return 2
        case .picture:  return 3
        case .video:    return 4
        case .sound:    return 5
        case .file:     return 6
        }
    }
    
    public static func getType(from: Int) -> MESSAGE_TYPE {
        switch from {
        case 1:     return MESSAGE_TYPE.text
        case 2:     return MESSAGE_TYPE.voice
        case 3:     return MESSAGE_TYPE.picture
        case 4:     return MESSAGE_TYPE.video
        case 5:     return MESSAGE_TYPE.sound
        case 6:     return MESSAGE_TYPE.file
        default:    return MESSAGE_TYPE.text
        }
    }
    
}

