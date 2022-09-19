//
//  RegisterAssistantRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/6/21.
//

import Foundation
public class DeactiveAssistantRequest : BaseRequest{
    
    public let assistants: [Assistant]
    
    public init(assistants: [Assistant], uniqueId: String? = nil) {
        self.assistants = assistants
        super.init(uniqueId: uniqueId)
    }
}
