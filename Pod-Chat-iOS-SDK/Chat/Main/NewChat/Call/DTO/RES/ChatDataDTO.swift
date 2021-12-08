//
//  ChatDataDTO.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public struct ChatDataDTO :Codable {
    
    public let screenShare        : String
    public let turnAddress        : String
    public let brokerAddressWeb   : String
    public let kurentoAddress     : String
    
    public init(sendMetaData: String, screenShare: String, reciveMetaData: String, turnAddress: String, brokerAddressWeb: String, kurentoAddress: String) {
        self.screenShare      = screenShare
        self.turnAddress      = turnAddress
        self.brokerAddressWeb = brokerAddressWeb
        self.kurentoAddress   = kurentoAddress
    }

    private enum CodingKeys:String , CodingKey{
        case screenShare        = "screenShare"
        case turnAddress        = "turnAddress"
        case brokerAddressWeb   = "brokerAddressWeb"
        case kurentoAddress     = "kurentoAddress"
    }
    
    public init(from decoder: Decoder) throws {
        let container    = try decoder.container(keyedBy: CodingKeys.self)
        screenShare      = try container.decode(String.self, forKey: .screenShare)
        
        if let firstTurnAddress      = try container.decode(String.self, forKey: .turnAddress).split(separator: ",").first{
            turnAddress = String(firstTurnAddress)
        }else{
            turnAddress = ""
        }
        
        if let brokerAddressWeb = try? container.decode(String.self, forKey: .brokerAddressWeb){
            self.brokerAddressWeb    = brokerAddressWeb
        }else{
            brokerAddressWeb    = ""
        }
        
        if let firstKurentoAddress   = try container.decode(String.self, forKey: .kurentoAddress).split(separator: ",").first{
            kurentoAddress = String(firstKurentoAddress)
        }else{
            kurentoAddress = ""
        }
    }
}
