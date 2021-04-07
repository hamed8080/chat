//
//  Contact.swift
//  Chat
//
//  Created by Mahyar Zhiani on 7/23/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON
open class Contact :Codable {
	
    /*
     *  + ContactVO          Contact:
     *      - blocked           Bool?
     *      - cellphoneNumber   String?
     *      - email             String?
     *      - firstName         String?
     *      - hasUser           Bool?
     *      - id                Int?
     *      - image             String?
     *      - lastName          String?
     *      - linkedUser        LinkedUser?
     *      - notSeenDuration   Int?
     *      - timeStamp         UInt?
     *      - uniqueId          Bool?
     *      - userId            Int?
     */
    
    public var blocked:         Bool?
    public var cellphoneNumber: String?
    public var email:           String?
    public var firstName:       String?
    public var hasUser:         Bool     = false
    public var id:              Int?
    public var image:           String?
    public var lastName:        String?
    public var linkedUser:      LinkedUser?
    public var notSeenDuration: Int?
    public var timeStamp:       UInt?
    public var userId:          Int?
    
    @available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(messageContent: JSON) {
        self.blocked            = messageContent["blocked"].bool
        self.cellphoneNumber    = messageContent["cellphoneNumber"].string
        self.email              = messageContent["email"].string
        self.firstName          = messageContent["firstName"].string
        self.id                 = messageContent["id"].int
        self.image              = messageContent["profileImage"].string
        self.lastName           = messageContent["lastName"].string
        self.notSeenDuration    = messageContent["notSeenDuration"].int
        self.timeStamp          = messageContent["timeStamp"].uInt
//        self.uniqueId           = messageContent["uniqueId"].string
        self.userId             = messageContent["userId"].int
        
        if (messageContent["hasUser"] != JSON.null) {
            self.hasUser = messageContent["hasUser"].boolValue
        }
        
        if (messageContent["linkedUser"] != JSON.null) {
            self.linkedUser = LinkedUser(messageContent: messageContent["linkedUser"])
            self.hasUser = true
        }
        
    }
    
    public init(blocked:            Bool? = nil,
                cellphoneNumber:    String? = nil,
                email:              String? = nil,
                firstName:          String? = nil,
                hasUser:            Bool,
                id:                 Int? = nil,
                image:              String? = nil,
                lastName:           String? = nil,
                linkedUser:         LinkedUser? = nil,
                notSeenDuration:    Int? = nil,
                timeStamp:          UInt? = nil,
//                uniqueId:           String?,
                userId:             Int? = nil) {
        
        self.blocked            = blocked 
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.firstName          = firstName
        self.hasUser            = hasUser
        self.id                 = id
        self.image              = image
        self.lastName           = lastName
        self.linkedUser         = linkedUser
        self.notSeenDuration    = notSeenDuration
        self.timeStamp          = timeStamp
//        self.uniqueId           = uniqueId
        self.userId             = userId
        
    }
    
	@available(*,deprecated , message:"Removed in XX.XX.XX version")
    public init(theContact: Contact) {
        
        self.blocked            = theContact.blocked
        self.cellphoneNumber    = theContact.cellphoneNumber
        self.email              = theContact.email
        self.firstName          = theContact.firstName
        self.hasUser            = theContact.hasUser
        self.id                 = theContact.id
        self.image              = theContact.image
        self.lastName           = theContact.lastName
        self.linkedUser         = theContact.linkedUser
        self.notSeenDuration    = theContact.notSeenDuration
        self.timeStamp          = theContact.timeStamp
        self.userId             = theContact.userId
    }
    
    
    public func formatDataToMakeContact() -> Contact {
        return self
    }
	@available(*,deprecated , message:"Removed in XX.XX.XX version")
	public func formatToJSON() -> JSON {
		let result: JSON = ["blocked":          blocked ?? NSNull(),
							"cellphoneNumber":  cellphoneNumber ?? NSNull(),
							"email":            email ?? NSNull(),
							"firstName":        firstName ?? NSNull(),
							"hasUser":          hasUser,
							"id":               id ?? NSNull(),
							"image":            image ?? NSNull(),
							"lastName":         lastName ?? NSNull(),
							"linkedUser":       linkedUser?.formatToJSON() ?? NSNull(),
							"notSeenDuration":  notSeenDuration ?? NSNull(),
							"timeStamp":        timeStamp ?? NSNull(),
							//                            "uniqueId":         uniqueId ?? NSNull(),
							"userId":           userId ?? NSNull()]
		return result
	}

	
	private enum CodingKeys:String,CodingKey{
		case blocked         	= "blocked"
		case cellphoneNumber 	= "cellphoneNumber"
		case email           	= "email"
		case firstName       	= "firstName"
		case lastName        	= "lastName"
		case hasUser         	= "hasUser"
		case id                 = "id"
		case image           	= "profileImage"
		case linkedUser      	= "linkedUser"
		case notSeenDuration  	= "notSeenDuration"
		case timeStamp          = "timeStamp"
		case userId          	= "userId"
	}
	
	public required init(from decoder: Decoder) throws {
        guard let container    = try? decoder.container(keyedBy: CodingKeys.self) else {return}
        blocked                = try container.decodeIfPresent(Bool.self, forKey: .blocked)
        cellphoneNumber        = try container.decodeIfPresent(String.self, forKey: .cellphoneNumber)
        email                  = try container.decodeIfPresent(String.self, forKey: .email)
        firstName              = try container.decodeIfPresent(String.self, forKey: .firstName)
        id                     = try container.decodeIfPresent(Int.self, forKey: .id)
        image                  = try container.decodeIfPresent(String.self, forKey: .image)
        lastName               = try container.decodeIfPresent(String.self, forKey: .lastName)
        notSeenDuration        = try container.decodeIfPresent(Int.self, forKey: .notSeenDuration)
        timeStamp              = try container.decodeIfPresent(UInt.self, forKey: .timeStamp)
        userId                 = try container.decodeIfPresent(Int.self, forKey: .userId)
        hasUser                = try container.decodeIfPresent(Bool.self, forKey: .hasUser) ?? false
        linkedUser             = try container.decodeIfPresent(LinkedUser.self, forKey: .linkedUser)
        if linkedUser != nil {
            hasUser = true
		}
	}
}
