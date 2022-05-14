//
//  CallClientErrorType.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 12/8/21.
//

import Foundation
public enum CallClientErrorType:Int, Codable{
    case MICROPHONE_NOT_AVAILABLE           = 3000
    case CAMERA_NOT_AVAILABLE               = 3001
}
