//
//  UserRole.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class UserRole : Codable {
    
    public var userId:      Int
    public var name:        String
    public var roles:       [String]?
    public var image:       String? = nil
//    public let threadId:    Int?
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(/*threadId: Int?, */messageContent: JSON) {
        
//        self.threadId   = threadId
        self.userId     = messageContent["id"].intValue
        self.name       = messageContent["name"].stringValue
//        for item in messageContent["roles"].arrayObject
        if let myRoles = messageContent["roles"].arrayObject as? [String]? {
            self.roles = myRoles
        }
    }
    
    public init(userId:     Int,
                name:       String,
                roles:      [String]?/*,
                threadId:   Int?*/) {
        
        self.userId     = userId
        self.name       = name
        self.roles      = roles
//        self.threadId   = threadId
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(theUserRole: UserRole) {
        self.userId     = theUserRole.userId
        self.name       = theUserRole.name
        self.roles      = theUserRole.roles
//        self.threadId   = theUserRole.threadId
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatDataToMakeRole() -> UserRole {
        return self
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatToJSON() -> JSON {
        let result: JSON = ["id":       userId,
                            "name":     name,
                            "roles":    roles ?? NSNull()/*,
                            "threadId": threadId ?? NSNull()*/]
        return result
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
