//
//  CallStatus.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public enum CallStatus : Int , Codable {
 
    case REQUESTED = 1
    case CANCELED  = 2
    case MISS      = 3
    case DECLINED  = 4
    case ACCEPTED  = 5
    case STARTED   = 6
    case ENDED     = 7
    case LEAVE     = 8
    
    case unknown
    
    //prevent crash when new case added from server side
    public init(from decoder: Decoder) throws {
        guard let value = try? decoder.singleValueContainer().decode(Int.self) else{
            self = .unknown
            return
        }
        self = CallStatus(rawValue: value) ?? .unknown
    }
    
}
