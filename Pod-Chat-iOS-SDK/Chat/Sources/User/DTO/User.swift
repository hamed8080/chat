//
//  User.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation

open class User : Codable {
    
    
    public var cellphoneNumber: String?
    public var contactSynced:   Bool
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
    
}
