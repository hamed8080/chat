//
//  FileRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/2/21.
//

import Foundation
public class FileRequest: BaseRequest {
    
    public let hashCode                  :String
    public let forceToDownloadFromServer :Bool
    
    public init(hashCode:String ,forceToDownloadFromServer:Bool = false ) {
        self.hashCode                  = hashCode
        self.forceToDownloadFromServer = forceToDownloadFromServer
    }
    
    private enum CodingKeys :String ,CodingKey{
        case hashCode = "hash"
        case uniqueId = " "
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(hashCode, forKey: .hashCode)
        try? container.encode(uniqueId, forKey: .uniqueId)
    }
}
