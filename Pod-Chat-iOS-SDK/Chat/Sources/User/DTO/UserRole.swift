//
//  UserRole.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation

open class UserRole : Codable {
    
    public var userId:      Int
    public var name:        String
    public var roles:       [String]?
    public var image:       String? = nil
    

    
    public init(userId:     Int,
                name:       String,
                roles:      [String]?) {
        
        self.userId     = userId
        self.name       = name
        self.roles      = roles
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
         name   = try container.decode(String.self, forKey: .name)
         roles  = try container.decode([String].self, forKey: .roles)
         userId = try container.decode(Int.self, forKey: .id)
         image  = try container.decodeIfPresent(String.self, forKey: .image)
    }
    
    private enum CodingKeys:String ,CodingKey{
        case name   = "name"
        case roles  = "roles"
        case image  = "image" //for decode
        case id     = "id"     //for encode
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(name, forKey: .name)
        try? container.encode(userId, forKey: .id)
        try? container.encodeIfPresent(roles, forKey: .roles)
    }
    
}