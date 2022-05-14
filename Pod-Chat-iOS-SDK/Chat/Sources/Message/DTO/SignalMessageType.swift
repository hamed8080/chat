//
//  SignalMessageType.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//
import Foundation

public enum SignalMessageType:Int , Encodable  , Decodable{
    
    case IS_TYPING      = 1
    case RECORD_VOICE   = 2
    case UPLOAD_PICTURE = 3
    case UPLOAD_VIDEO   = 4
    case UPLOAD_SOUND   = 5
    case UPLOAD_FILE    = 6
    case unknown
    
    //prevent crash when new case added from server side
    public init(from decoder: Decoder) throws {
        guard let value = try? decoder.singleValueContainer().decode(Int.self) else{
            self = .unknown
            return
        }
        self = SignalMessageType(rawValue: value) ?? .unknown
    }
    
}


