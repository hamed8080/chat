//
//  GetAllThreadsRequest.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 10/16/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


class GetAllThreadsRequest {
    
    public let summary:     Bool
    
    public let typeCode:    String?
    
    init(summary:   Bool,
         typeCode:  String?) {
        self.summary    = summary
        self.typeCode   = typeCode
    }
    
    func convertContentToJSON() -> JSON {
        let content: JSON = ["summary": self.summary]
        return content
    }
    
}

