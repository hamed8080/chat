//
//  UNMuteCallRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public class CallClientErrorRequest:BaseRequest{
    
    let code       : CallClientErrorType
    let callId     : Int
    
    public init(callId:Int, code:CallClientErrorType, typeCode:String? = nil, uniqueId:String? = nil) {
        self.callId     = callId
        self.code       = code
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }

    private enum CodingKeys:String,CodingKey{
        case code = "code"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code.rawValue, forKey: .code)
    }
    
}
