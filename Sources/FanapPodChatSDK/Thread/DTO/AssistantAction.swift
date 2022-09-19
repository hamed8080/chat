//
//  AssistantAction.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation

public class AssistantAction : Decodable {
    
    public var actionName  : String?
    public var actionTime  : UInt?
    public var actionType  : Int?
    public var participant : Participant?
    
    
    private enum CodingKeys:String,CodingKey{
        case actionName    = "actionName"
        case actionTime    = "actionTime"
        case actionType    = "actionType"
        case participantVO = "participantVO"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        actionName    = try container?.decodeIfPresent(String.self, forKey: .actionName)
        actionTime    = try container?.decodeIfPresent(UInt.self, forKey: .actionTime)
        actionType    = try container?.decodeIfPresent(Int.self, forKey: .actionType)
        participant   = try container?.decodeIfPresent(Participant.self, forKey: .participantVO)
    }
    
}
