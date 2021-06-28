//
//  NewChatMessage.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/22/21.
//

import Foundation
import SwiftyJSON

struct NewChatMessage : Decodable {
    
    var code               : Int?
    let content            : String?
    let contentCount       : Int?
    var message            : String?
    let messageType        : Int
    let subjectId          : Int?
    let time               : Int
    let type               : NewChatMessageVOTypes
    let uniqueId           : String
    var messageId          : Int? = nil
    var participantId      : Int? = nil
    
    private enum CodingKeys:String , CodingKey{
        case code
        case content
        case contentCount
        case message
        case messageType
        case subjectId
        case time
        case type
        case uniqueId
        case messageId
        case participantId
    }
    
    init(from decoder: Decoder) throws {
        let container     = try     decoder.container(keyedBy: CodingKeys.self)
        code              = try? container.decode(Int.self, forKey: .code)
        content           = try? container.decode(String.self, forKey : .content)
        contentCount      = try? container.decode(Int.self, forKey : .contentCount)
        message           = try? container.decode(String.self, forKey: .message)
        messageType       = try  container.decode(Int.self, forKey : .messageType)
        subjectId         = try? container.decode(Int.self, forKey : .subjectId)
        time              = try  container.decode(Int.self, forKey : .time)
        type              = try  container.decode(NewChatMessageVOTypes.self, forKey : .type)
        if let uniqueId = try container.decodeIfPresent(String.self, forKey: .uniqueId){
            self.uniqueId = uniqueId
        }else{
            uniqueId = "" //some messages like system message type = 46 dont have unique id
        }
        messageId         = try? container.decode(Int.self, forKey : .messageId)
        participantId     = try? container.decode(Int.self, forKey : .participantId)
        if let content = content{
            let jsonContent = JSON(parseJSON: content)
            if(participantId == nil){
                participantId = jsonContent["participantId"].int  ?? JSON(content)["participantId"].int
            }
            if(messageId == nil){
                participantId = jsonContent["messageId"].int ?? JSON(content)["messageId"].int
            }
        }
        
    }
}
