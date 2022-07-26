//
//  AllThreads.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/4/21.
//

import Foundation
public class AllThreads : BaseRequest{
    
    private let summary:Bool

    /// Init the request.
    /// - Parameters:
    ///   - summary: If it set to true the result only contains the ids of threads not other properties.
    ///   - uniqueId: The optional uniqueId.
    public init(summary:Bool = false, uniqueId: String? = nil) {
        self.summary = summary
        super.init(uniqueId: uniqueId)
    }
    
    private enum CodingKeys :String ,CodingKey{
        case summary = "summary"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(summary, forKey: .summary)
    }
}
