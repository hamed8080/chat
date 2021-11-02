//
//  StartCall.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public struct StartCall:Codable {
    
    public let certificateFile  : String
    public let clientDTO        : ClientDTO
    public let callName         : String?
    public let callImage        : String?
    public var callId           : Int?
    
    
    private enum CodingKeys:String , CodingKey{
        
        case certificateFile  = "cert_file"
        case clientDTO        = "clientDTO"
        case callName         = "callName"
        case callImage        = "callImage"
    }
    
}
