//
//  AddContactRequest.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/12/21.
//

import Foundation

public class AddContactRequest : BaseRequest {
    
    public var cellphoneNumber:    String?
    public var email:              String?
    public var firstName:          String?
    public var lastName:           String?
    public var ownerId:            Int?
    public var username:           String?

    
    public init(cellphoneNumber    : String? = nil,
                email              : String? = nil,
                firstName          : String? = nil,
                lastName           : String? = nil,
                ownerId            : Int?    = nil,
                uniqueId           : String? = nil) {
        
        self.cellphoneNumber    = cellphoneNumber
        self.email              = email
        self.firstName          = firstName
        self.lastName           = lastName
        self.ownerId            = ownerId
        self.username           = nil
        super.init(uniqueId: uniqueId)
    }
    
    /// Add Contact with username
    public init(email:      String?,
                firstName:  String?,
                lastName:   String?,
                ownerId:    Int?,
                username:   String?,
                uniqueId:   String?) {
        
        self.cellphoneNumber    = ""
        self.email              = email ?? ""
        self.firstName          = firstName
        self.lastName           = lastName
        self.ownerId            = ownerId
        self.username           = username
        super.init(uniqueId: uniqueId)
    }
    
    
    private enum CodingKeys : String , CodingKey{
        case cellphoneNumber = "cellphoneNumber"
        case email           = "email"
        case firstName       = "firstName"
        case lastName        = "lastName"
        case ownerId         = "ownerId"
        case username        = "username"
        case uniqueId        = "uniqueId"
        case typeCode        = "typeCode"
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cellphoneNumber, forKey: .cellphoneNumber)
        try container.encode(email, forKey: .email)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encodeIfPresent(ownerId, forKey: .ownerId)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
        try container.encodeIfPresent(Chat.sharedInstance.config?.typeCode, forKey: .typeCode)
    }
}
