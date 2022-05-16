//
//  User.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation

open class User : Codable {
    
    
    public var cellphoneNumber: String?
    public var contactSynced:   Bool = false
    public var coreUserId:      Int?
    public var email:           String?
    public var id:              Int?
    public var image:           String?
    public var lastSeen:        Int?
    public var name:            String?
    public var receiveEnable:   Bool?
    public var sendEnable:      Bool?
    public var username:        String?
    public var chatProfileVO:   Profile?
    
    
    public init(cellphoneNumber:    String?,
                contactSynced:      Bool?,
                coreUserId:         Int?,
                email:              String?,
                id:                 Int?,
                image:              String?,
                lastSeen:           Int?,
                name:               String?,
                receiveEnable:      Bool?,
                sendEnable:         Bool?,
                username:           String?,
                chatProfileVO:      Profile?) {
        
        self.cellphoneNumber    = cellphoneNumber
        self.contactSynced      = contactSynced ?? false
        self.coreUserId         = coreUserId
        self.email              = email
        self.id                 = id
        self.image              = image
        self.lastSeen           = lastSeen
        self.name               = name
        self.receiveEnable      = receiveEnable
        self.sendEnable         = sendEnable
        self.username           = username
        self.chatProfileVO      = chatProfileVO
    }
    
    private enum CodingKeys: String , CodingKey{
        case cellphoneNumber = "cellphoneNumber"
        case contactSynced   = "contactSynced"
        case coreUserId      = "coreUserId"
        case email           = "email"
        case id              = "id"
        case image           = "image"
        case lastSeen        = "lastSeen"
        case name            = "name"
        case receiveEnable   = "receiveEnable"
        case sendEnable      = "sendEnable"
        case username        = "username"
        case chatProfileVO   = "chatProfileVO"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        cellphoneNumber = try container.decodeIfPresent(String.self, forKey  : .cellphoneNumber)
        contactSynced   = try container.decodeIfPresent(Bool.self, forKey    : .contactSynced) ?? false
        coreUserId      = try container.decodeIfPresent(Int.self, forKey     : .coreUserId)
        email           = try container.decodeIfPresent(String.self, forKey  : .email)
        id              = try container.decodeIfPresent(Int.self, forKey     : .id)
        image           = try container.decodeIfPresent(String.self, forKey  : .image)
        lastSeen        = try container.decodeIfPresent(Int.self, forKey     : .lastSeen)
        name            = try container.decodeIfPresent(String.self, forKey  : .name)
        receiveEnable   = try container.decodeIfPresent(Bool.self, forKey    : .receiveEnable)
        sendEnable      = try container.decodeIfPresent(Bool.self, forKey    : .sendEnable)
        username        = try container.decodeIfPresent(String.self, forKey  : .username)
        chatProfileVO   = try container.decodeIfPresent(Profile.self, forKey : .chatProfileVO)
        
    }
    
}
