//
//  SMT.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation

public enum SMT : Int ,Codable{
    case IS_TYPING      = 1
    case RECORD_VOICE   = 2
    case UPLOAD_PICTURE = 3
    case UPLOAD_VIDEO   = 4
    case UPLOAD_SOUND   = 5
    case UPLOAD_FILE    = 6
    case SERVER_TIME    = -1
}
