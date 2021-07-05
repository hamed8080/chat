//
//  StartCall.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public struct StartCall:Codable {
    
    public let cert_file : String
    public let clientDTO : ClientDTO
    public let callName  : String
    public let callImage : String
}
