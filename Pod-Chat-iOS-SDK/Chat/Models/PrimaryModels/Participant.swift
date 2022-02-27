//
//  Participant.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Participant : Codable , Hashable{
    
    public static func == (lhs: Participant, rhs: Participant) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var admin:               Bool?
    public var auditor:             Bool?
    public var blocked:             Bool?
    public var cellphoneNumber:     String?
    public var contactFirstName:    String?
    public var contactId:           Int?
    public var contactName:         String?
    public var contactLastName:     String?
    public var coreUserId:      Int?
    public var email:           String?
    public var firstName:       String?
    public var id:              Int?
    public var image:           String?
    public var keyId:           String?
    public var lastName:        String?
    public var myFriend:        Bool?
    public var name:            String?
    public var notSeenDuration: Int?
    public var online:          Bool?
    public var receiveEnable:   Bool?
    public var roles:           [String]?
    public var sendEnable:      Bool?
    public var username:        String?
    public var chatProfileVO:   Profile?
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public init(messageContent: JSON, threadId: Int?) {
        self.admin              = messageContent["admin"].bool
        self.auditor            = messageContent["auditor"].bool
        self.blocked            = messageContent["blocked"].bool
        self.cellphoneNumber    = messageContent["cellphoneNumber"].string
        self.contactFirstName   = messageContent["contactFirstName"].string
        self.contactId          = messageContent["contactId"].int
        self.contactName        = messageContent["contactName"].string
        self.contactLastName    = messageContent["contactLastName"].string
        self.coreUserId         = messageContent["coreUserId"].int
        self.email              = messageContent["email"].string
        self.firstName          = messageContent["firstName"].string
        self.id                 = messageContent["id"].int //?? ( (messageContent["id"].string != nil) ? Int(messageContent["id"].stringValue) : nil )
        self.image              = messageContent["image"].string
        self.keyId              = messageContent["keyId"].string
        self.lastName           = messageContent["lastName"].string
        self.myFriend           = messageContent["myFriend"].bool
        self.name               = messageContent["name"].string
        self.notSeenDuration    = messageContent["notSeenDuration"].int
        self.online             = messageContent["online"].bool
        self.receiveEnable      = messageContent["receiveEnable"].bool
        self.sendEnable         = messageContent["sendEnable"].bool
        self.username           = messageContent["username"].string
        
        if let profileJSON = messageContent["chatProfileVO"] as JSON?, (profileJSON != JSON.null) {
            self.chatProfileVO = Profile(messageContent: profileJSON)
        }
        
        var adminRoles = [String]()
        if let myRoles = messageContent["roles"].arrayObject as! [String]? {
            for role in myRoles {
                adminRoles.append(role)
            }
        }
        if (adminRoles.count > 0) {
            self.roles = adminRoles
        }
//         ?  : (self.roles = nil)
        
    }
    
    public init(admin:              Bool?,
                auditor:            Bool?,
                blocked:            Bool?,
                cellphoneNumber:    String?,
                contactFirstName:   String?,
                contactId:          Int?,
                contactName:        String?,
                contactLastName:    String?,
                coreUserId:         Int?,
                email:              String?,
                firstName:          String?,
                id:                 Int?,
                image:              String?,
                keyId:              String?,
                lastName:           String?,
                myFriend:           Bool?,
                name:               String?,
                notSeenDuration:    Int?,
                online:             Bool?,
                receiveEnable:      Bool?,
                roles:              [String]?,
                sendEnable:         Bool?,
                username:           String?,
                chatProfileVO:      Profile?) {
        
        self.admin              = admin
        self.auditor            = auditor
        self.blocked            = blocked
        self.cellphoneNumber    = cellphoneNumber
        self.contactFirstName   = contactFirstName
        self.contactId          = contactId
        self.contactName        = contactName
        self.contactLastName    = contactLastName
        self.coreUserId         = coreUserId
        self.email              = email
        self.firstName          = firstName
        self.id                 = id
        self.image              = image
        self.keyId              = keyId
        self.lastName           = lastName
        self.myFriend           = myFriend
        self.name               = name
        self.notSeenDuration    = notSeenDuration
        self.online             = online
        self.receiveEnable      = receiveEnable
        self.roles              = roles
        self.sendEnable         = sendEnable
        self.username           = username
        self.chatProfileVO      = chatProfileVO
    }
    
    public init(theParticipant: Participant) {
        
        self.admin              = theParticipant.admin
        self.auditor            = theParticipant.auditor
        self.blocked            = theParticipant.blocked
        self.cellphoneNumber    = theParticipant.cellphoneNumber
        self.contactFirstName   = theParticipant.contactFirstName
        self.contactId          = theParticipant.contactId
        self.contactName        = theParticipant.contactName
        self.contactLastName    = theParticipant.contactLastName
        self.coreUserId         = theParticipant.coreUserId
        self.email              = theParticipant.email
        self.firstName          = theParticipant.firstName
        self.id                 = theParticipant.id
        self.image              = theParticipant.image
        self.keyId              = theParticipant.keyId
        self.lastName           = theParticipant.lastName
        self.myFriend           = theParticipant.myFriend
        self.name               = theParticipant.name
        self.notSeenDuration    = theParticipant.notSeenDuration
        self.online             = theParticipant.online
        self.receiveEnable      = theParticipant.receiveEnable
        self.roles              = theParticipant.roles
        self.sendEnable         = theParticipant.sendEnable
        self.username           = theParticipant.username
        self.chatProfileVO      = theParticipant.chatProfileVO
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatDataToMakeParticipant() -> Participant {
        return self
    }
    
    @available(*,deprecated , message:"Removed in 0.10.5.0 version")
    public func formatToJSON() -> JSON {
        let result: JSON = ["admin":            admin ?? NSNull(),
                            "auditor":          auditor ?? NSNull(),
                            "blocked":          blocked ?? NSNull(),
                            "cellphoneNumber":  cellphoneNumber ?? NSNull(),
                            "contactFirstName": contactFirstName ?? NSNull(),
                            "contactId":        contactId ?? NSNull(),
                            "contactName":      contactName ?? NSNull(),
                            "contactLastName":  contactLastName ?? NSNull(),
                            "coreUserId":       coreUserId ?? NSNull(),
                            "email":            email ?? NSNull(),
                            "firstName":        firstName ?? NSNull(),
                            "id":               id ?? NSNull(),
                            "image":            image ?? NSNull(),
                            "keyId":            keyId ?? NSNull(),
                            "lastName":         lastName ?? NSNull(),
                            "myFriend":         myFriend ?? NSNull(),
                            "name":             name ?? NSNull(),
                            "notSeenDuration":  notSeenDuration ?? NSNull(),
                            "online":           online ?? NSNull(),
                            "receiveEnable":    receiveEnable ?? NSNull(),
                            "roles":            roles ?? NSNull(),
                            "sendEnable":       sendEnable ?? NSNull(),
                            "username":         username ?? NSNull(),
                            "chatProfileVO":    (chatProfileVO != nil) ? (chatProfileVO!.formatToJSON()) : (NSNull())]
        return result
    }
    
	private enum CodingKeys: String ,CodingKey{
		case admin  = "admin"
		case auditor = "auditor"
		case blocked = "blocked"
		case cellphoneNumber = "cellphoneNumber"
		case contactFirstName = "contactFirstName"
		case contactId = "contactId"
		case contactName = "contactName"
		case contactLastName = "contactLastName"
		case coreUserId = "coreUserId"
		case email = "email"
		case firstName = "firstName"
		case id = "id"
		case image = "image"
		case keyId = "keyId"
		case lastName = "lastName"
		case myFriend = "myFriend"
		case name = "name"
		case notSeenDuration = "notSeenDuration"
		case online = "online"
		case receiveEnable = "receiveEnable"
		case sendEnable = "sendEnable"
		case username = "username"
		case chatProfileVO = "chatProfileVO"
		case roles = "roles"
	}
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.admin  = try container.decodeIfPresent(Bool.self, forKey: .admin)
		self.auditor              =  try container.decodeIfPresent(Bool.self, forKey: .auditor)
		self.blocked              =  try container.decodeIfPresent(Bool.self, forKey: .blocked)
		self.cellphoneNumber              =  try container.decodeIfPresent(String.self, forKey: .cellphoneNumber)
		self.contactFirstName              =  try container.decodeIfPresent(String.self, forKey: .contactFirstName)
		self.contactId              =  try container.decodeIfPresent(Int.self, forKey: .contactId)
		self.contactName              =  try container.decodeIfPresent(String.self, forKey: .contactName)
		self.contactLastName              =  try container.decodeIfPresent(String.self, forKey: .contactLastName)
		self.coreUserId              =  try container.decodeIfPresent(Int.self, forKey: .coreUserId)
		self.email              =  try container.decodeIfPresent(String.self, forKey: .email)
		self.firstName              =  try container.decodeIfPresent(String.self, forKey: .firstName)
		self.id              =  try container.decodeIfPresent(Int.self, forKey: .id)
		self.image              =  try container.decodeIfPresent(String.self, forKey: .image)
		self.keyId              =  try container.decodeIfPresent(String.self, forKey: .keyId)
		self.lastName              =  try container.decodeIfPresent(String.self, forKey: .lastName)
		self.myFriend              =  try container.decodeIfPresent(Bool.self, forKey: .myFriend)
		self.name              =  try container.decodeIfPresent(String.self, forKey: .name)
		self.notSeenDuration              =  try container.decodeIfPresent(Int.self, forKey: .notSeenDuration)
		self.online              =  try container.decodeIfPresent(Bool.self, forKey: .online)
		self.receiveEnable              =  try container.decodeIfPresent(Bool.self, forKey: .receiveEnable)
		self.sendEnable              =  try container.decodeIfPresent(Bool.self, forKey: .sendEnable)
		self.username              =  try container.decodeIfPresent(String.self, forKey: .username)
		self.chatProfileVO         =  try container.decodeIfPresent(Profile.self, forKey: .chatProfileVO)
		self.roles         =  try container.decodeIfPresent([String].self, forKey: .roles)
	}
}
