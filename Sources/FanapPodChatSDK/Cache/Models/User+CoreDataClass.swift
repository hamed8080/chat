//
//  User+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class User: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cellphoneNumber = try container.decodeIfPresent(String.self, forKey: .cellphoneNumber)
        contactSynced = (try container.decodeIfPresent(Bool.self, forKey: .contactSynced) ?? false) as NSNumber?
        coreUserId = try container.decodeIfPresent(Int.self, forKey: .coreUserId) as? NSNumber
        email = try container.decodeIfPresent(String.self, forKey: .email)
        id = try container.decodeIfPresent(Int.self, forKey: .id) as? NSNumber
        image = try container.decodeIfPresent(String.self, forKey: .image)
        lastSeen = try container.decodeIfPresent(Int.self, forKey: .lastSeen) as? NSNumber
        name = try container.decodeIfPresent(String.self, forKey: .name)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        receiveEnable = try container.decodeIfPresent(Bool.self, forKey: .receiveEnable) as? NSNumber
        sendEnable = try container.decodeIfPresent(Bool.self, forKey: .sendEnable) as? NSNumber
        username = try container.decodeIfPresent(String.self, forKey: .username)
        let profile = try container.decodeIfPresent(Profile.self, forKey: .chatProfileVO)
        bio = profile?.bio
        metadata = profile?.metadata
        ssoId = try container.decodeIfPresent(String.self, forKey: .ssoId)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
    }
}

public extension User {
    convenience init(
        context: NSManagedObjectContext,
        cellphoneNumber: String? = nil,
        contactSynced: Bool? = nil,
        coreUserId: Int? = nil,
        email: String? = nil,
        id: Int? = nil,
        image: String? = nil,
        lastSeen: Int? = nil,
        name: String? = nil,
        nickname: String? = nil,
        receiveEnable: Bool? = nil,
        sendEnable: Bool? = nil,
        username: String? = nil,
        ssoId: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        profile: Profile? = nil
    ) {
        self.init(context: context)
        self.cellphoneNumber = cellphoneNumber
        self.contactSynced = (contactSynced ?? false) as NSNumber?
        self.coreUserId = coreUserId as? NSNumber
        self.email = email
        self.id = id as? NSNumber
        self.image = image
        self.lastSeen = lastSeen as? NSNumber
        self.name = name
        self.nickname = nickname
        self.receiveEnable = receiveEnable as? NSNumber
        self.sendEnable = sendEnable as? NSNumber
        self.username = username
        self.ssoId = ssoId
        self.lastName = lastName
        self.firstName = firstName
        bio = profile?.bio
        metadata = profile?.metadata
    }

    private enum CodingKeys: String, CodingKey {
        case cellphoneNumber
        case contactSynced
        case coreUserId
        case nickname
        case email
        case id
        case image
        case lastSeen
        case name
        case receiveEnable
        case sendEnable
        case username
        case chatProfileVO
        case ssoId
        case firstName
        case lastName
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(cellphoneNumber, forKey: .cellphoneNumber)
        try container.encodeIfPresent(contactSynced as? Bool, forKey: .contactSynced)
        try container.encodeIfPresent(coreUserId as? Int, forKey: .coreUserId)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(id as? Int, forKey: .id)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(lastSeen as? Int, forKey: .lastSeen)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(nickname, forKey: .nickname)
        try container.encodeIfPresent(receiveEnable as? Bool, forKey: .receiveEnable)
        try container.encodeIfPresent(sendEnable as? Bool, forKey: .sendEnable)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(ssoId, forKey: .ssoId)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(Profile(bio: bio, metadata: metadata), forKey: .chatProfileVO)
    }
}

//
// public extension CMUser {
//
//    class func insertOrUpdate(user: User, resultEntity: ((CMUser) -> Void)? = nil) {
//        if let findedEntity = CMUser.crud.find(keyWithFromat: "id == %i", value: user.id!) {
//            let cmUser = converUserToCM(user: user, entity: findedEntity)
//            resultEntity?(cmUser)
//        } else {
//            CMUser.crud.insert { cmUserEntity in
//                let cmUser = converUserToCM(user: user, entity: cmUserEntity)
//                resultEntity?(cmUser)
//            }
//        }
//    }
// }
