//
//  MessageType.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/6/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation

public enum MessageType {
    
    case text
    case voice
    case picture
    case video
    case sound
    case file
    case link
    
    public func returnIntValue() -> Int {
        switch self {
        case .text:     return 1
        case .voice:    return 2
        case .picture:  return 3
        case .video:    return 4
        case .sound:    return 5
        case .file:     return 6
        case .link:     return 7
        }
    }
    
    public static func getType(from: Int) -> MessageType {
        switch from {
        case 1:     return MessageType.text
        case 2:     return MessageType.voice
        case 3:     return MessageType.picture
        case 4:     return MessageType.video
        case 5:     return MessageType.sound
        case 6:     return MessageType.file
        case 7:     return MessageType.link
        default:    return MessageType.text
        }
    }
    
}

