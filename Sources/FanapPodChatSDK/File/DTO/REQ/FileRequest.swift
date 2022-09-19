//
//  FileRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/2/21.
//

import Foundation
public class FileRequest: BaseRequest {
    
    public let hashCode                  :String
    public let checkUserGroupAccess      :Bool
    public var forceToDownloadFromServer :Bool
    
    public init(hashCode:String , checkUserGroupAccess:Bool = true  ,forceToDownloadFromServer:Bool = false  ) {
        self.hashCode                  = hashCode
        self.forceToDownloadFromServer = forceToDownloadFromServer
        self.checkUserGroupAccess      = checkUserGroupAccess
    }
    
    private enum CodingKeys :String ,CodingKey{
        case uniqueId             = "uniqueId"
        case checkUserGroupAccess = "checkUserGroupAccess"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(uniqueId, forKey: .uniqueId)
        try? container.encode(checkUserGroupAccess, forKey: .checkUserGroupAccess)
    }
}
