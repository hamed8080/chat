//
//  CreateSessionReq.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import Foundation

class CreateSessionReq: BaseRequest {
   
    var id            :String = "CREATE_SESSION"
    var brokerAddress :String
    var turnAddress   :String
    var token         :String
    
    public init(id: String = "CREATE_SESSION", turnAddress:String, brokerAddress: String, token: String,uniqueId:String? = nil , typeCode:String? = nil) {
        self.id            = id
        self.turnAddress   = turnAddress
        self.brokerAddress = brokerAddress
        self.token         = token
        super.init(uniqueId:uniqueId,typeCode:typeCode)
    }
    
    private enum CodingKeys:String,CodingKey{
        case id            = "id"
        case turnAddress   = "turnAddress"
        case brokerAddress = "brokerAddress"
        case token         = "token"
        case uniqueId      = "uniqueId"
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(turnAddress, forKey: .turnAddress)
        try container.encode(brokerAddress, forKey: .brokerAddress)
        try container.encode(token, forKey: .token)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
    }
    
}
