//
//  CallErrorVO.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public struct CallError:Codable {

    public var code        :CallClientErrorType?
    public var message     :String?
    public var participant :Participant
    
    public init(code : CallClientErrorType?  = nil, message : String? = nil, participant : Participant) {
        self.code            = code
        self.message         = message
        self.participant     = participant
    }
    
    private enum CodingKeys:String , CodingKey{
        case code        = "code"
        case message     = "message"
        case participant = "participant"
    }
    
}
