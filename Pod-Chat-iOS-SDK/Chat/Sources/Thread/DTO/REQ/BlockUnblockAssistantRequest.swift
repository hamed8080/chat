//
//  BlockUnblockAssistantRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/13/21.
//

import Foundation
public class BlockUnblockAssistantRequest: BaseRequest {
    
    internal let assistants : [Assistant]
    
    public required init (assistants:[Assistant], uniqueId:String? = nil){
        self.assistants = assistants
        super.init(uniqueId: uniqueId)
    }
    
}
