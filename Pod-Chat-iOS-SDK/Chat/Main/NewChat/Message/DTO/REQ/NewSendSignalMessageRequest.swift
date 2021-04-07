//
//  NewSendSignalMessageRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/10/21.
//

import Foundation
public class NewSendSignalMessageRequest: BaseRequest {
    
    public let signalType:  SignalMessageType
    public let threadId:    Int
    
    public init(signalType: SignalMessageType,threadId:Int,uniqueId:String? = nil) {
        self.signalType = signalType
        self.threadId   = threadId
        super.init(uniqueId: uniqueId, typeCode: nil)
    }
    
    private enum CodingKeys:String,CodingKey{
        case type = "type"
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("\(signalType.rawValue)", forKey: .type)
    }
    
}
