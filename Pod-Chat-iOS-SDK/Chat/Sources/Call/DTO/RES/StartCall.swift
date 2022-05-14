//
//  StartCall.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public struct StartCall:Codable {
    
    public let certificateFile           : String
    public let clientDTO                 : ClientDTO
    public let otherClientDtoList        : [ClientDTO]?
    public let chatDataDto               : ChatDataDTO
    public let callName                  : String?
    public let callImage                 : String?
    public var callId                    : Int?
    
    public init(certificateFile: String, clientDTO: ClientDTO, otherClientDtoList: [ClientDTO]? = nil, chatDataDto: ChatDataDTO, callName: String?, callImage: String?, callId: Int? = nil) {
        self.certificateFile    = certificateFile
        self.clientDTO          = clientDTO
        self.otherClientDtoList = otherClientDtoList
        self.chatDataDto        = chatDataDto
        self.callName           = callName
        self.callImage          = callImage
        self.callId             = callId
    }
    
    
    private enum CodingKeys:String , CodingKey{
        
        case certificateFile            = "cert_file"
        case clientDTO                  = "clientDTO"
        case otherClientDtoList         = "otherClientDtoList"
        case callName                   = "callName"
        case callImage                  = "callImage"
        case chatDataDto                = "chatDataDto"
    }
    
}
