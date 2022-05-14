//
//  DeleteMessageReponse.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/26/21.
//

import Foundation
public class DeleteMessage: Decodable {
    
    
    public let messageId:   Int
    public let messageType: Int
    public let edited:      Bool
    public let editable:    Bool
    public let deletable:   Bool
    public let mentioned:   Bool
    public let pinned:      Bool
    
    private enum CodingKeys : String , CodingKey {
        case  id        = "id"
        case  type      = "messageType"
        case  edited    = "edited"
        case  editable  = "editable"
        case  deletable = "deletable"
        case  mentioned = "mentioned"
        case  pinned    = "pinned"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageId     = try container.decode(Int.self, forKey: .id)
        messageType   = try container.decode(Int.self, forKey: .type)
        edited        = try container.decode(Bool.self, forKey: .edited)
        editable      = try container.decode(Bool.self, forKey: .editable)
        deletable     = try container.decode(Bool.self, forKey: .deletable)
        mentioned     = try container.decode(Bool.self, forKey: .mentioned)
        pinned        = try container.decode(Bool.self, forKey: .pinned)
    }
    
}
