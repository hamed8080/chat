//
//  SignalMessageType.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//
import Foundation

public enum SignalMessageType: Int, Encodable, SafeDecodable{
    
    case IS_TYPING      = 1
    case RECORD_VOICE   = 2
    case UPLOAD_PICTURE = 3
    case UPLOAD_VIDEO   = 4
    case UPLOAD_SOUND   = 5
    case UPLOAD_FILE    = 6

    /// Only when can't decode a type.
    ///
    /// Do not remove or move this property to the top of the enum, it must be the last enum because it uses ``SafeDecodable`` to decode the last item if no match found.
    case UNKNOWN
    
}


