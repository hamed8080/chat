//
//  RegisterAssistantRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/6/21.
//

import Foundation
public class RegisterAssistantRequest : BaseRequest{
    
    public let assistants: [Assistant]
    
    public init(assistants: [Assistant], typeCode: String? = nil, uniqueId: String? = nil) {
        self.assistants = assistants
        super.init(uniqueId: uniqueId, typeCode: typeCode)
    }
}
