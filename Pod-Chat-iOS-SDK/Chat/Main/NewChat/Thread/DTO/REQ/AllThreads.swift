//
//  AllThreads.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/4/21.
//

import Foundation
public class AllThreads : BaseRequest{
    
    private let summary:Bool
    
    public init( summary:Bool = false , uniqueId: String? = nil, typeCode: String? = nil) {
        self.summary = summary
        super.init(uniqueId: uniqueId, typeCode: typeCode)        
    }
    
    private enum CodingKeys :String ,CodingKey{
        case summary  = "summary"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(summary , forKey: .summary)
    }
}
