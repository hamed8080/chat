//
//  BlockedContact.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation

open class BlockedContact : Decodable {
    
    public var id:          Int?
    public var coreUserId:  Int?
    public var firstName:   String?
    public var lastName:    String?
    public var nickName:    String?
    public var profileImage: String?
    public var contact:     Contact?
    
    public init(id:         Int?,
                coreUserId: Int?,
                firstName:  String?,
                lastName:   String?,
                nickName:   String?,
                profileImage: String?,
                contact:    Contact?) {
        
        self.id             = id
        self.coreUserId     = coreUserId
        self.firstName      = firstName
        self.lastName       = lastName
        self.nickName       = nickName
        self.profileImage   = profileImage
        self.contact        = contact
    }

	private enum CodingKeys:String ,CodingKey{
        case id           = "id"
        case coreUserId   = "coreUserId"
        case firstName    = "firstName"
        case lastName     = "lastName"
        case nickName     = "nickName"
		case profileImage = "profileImage"
        case contact      = "contactVO"
	}
	
	public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id            = try container.decodeIfPresent(Int.self, forKey: .id)
        coreUserId    = try container.decodeIfPresent(Int.self, forKey: .coreUserId)
        firstName     = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName      = try container.decodeIfPresent(String.self, forKey: .lastName)
        nickName      = try container.decodeIfPresent(String.self, forKey: .nickName)
        profileImage  = try container.decodeIfPresent(String.self, forKey: .profileImage)
        contact       = try container.decodeIfPresent(Contact.self, forKey: .contact)
    }
}


