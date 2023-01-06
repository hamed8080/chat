//
//  Participant+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class Participant: NSManagedObject, Codable, Identifiable {
    var chatProfileVO: Profile?
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        admin = try container.decodeIfPresent(Bool.self, forKey: .admin) as? NSNumber
        auditor = try container.decodeIfPresent(Bool.self, forKey: .auditor) as? NSNumber
        blocked = try container.decodeIfPresent(Bool.self, forKey: .blocked) as? NSNumber
        cellphoneNumber = try container.decodeIfPresent(String.self, forKey: .cellphoneNumber)
        contactFirstName = try container.decodeIfPresent(String.self, forKey: .contactFirstName)
        contactId = try container.decodeIfPresent(Int.self, forKey: .contactId) as? NSNumber
        contactName = try container.decodeIfPresent(String.self, forKey: .contactName)
        contactLastName = try container.decodeIfPresent(String.self, forKey: .contactLastName)
        coreUserId = try container.decodeIfPresent(Int.self, forKey: .coreUserId) as? NSNumber
        email = try container.decodeIfPresent(String.self, forKey: .email)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        id = try container.decodeIfPresent(Int.self, forKey: .id) as? NSNumber
        image = try container.decodeIfPresent(String.self, forKey: .image)
        keyId = try container.decodeIfPresent(String.self, forKey: .keyId)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        myFriend = try container.decodeIfPresent(Bool.self, forKey: .myFriend) as? NSNumber
        name = try container.decodeIfPresent(String.self, forKey: .name)
        notSeenDuration = try container.decodeIfPresent(Int.self, forKey: .notSeenDuration) as? NSNumber
        online = try container.decodeIfPresent(Bool.self, forKey: .online) as? NSNumber
        receiveEnable = try container.decodeIfPresent(Bool.self, forKey: .receiveEnable) as? NSNumber
        sendEnable = try container.decodeIfPresent(Bool.self, forKey: .sendEnable) as? NSNumber
        username = try container.decodeIfPresent(String.self, forKey: .username)
        chatProfileVO = try container.decodeIfPresent(Profile.self, forKey: .chatProfileVO)
        roles = try container.decodeIfPresent([Roles].self, forKey: .roles)
    }
}

public extension Participant {
    static func == (lhs: Participant, rhs: Participant) -> Bool {
        lhs.id == rhs.id
    }

    convenience init(
        context: NSManagedObjectContext,
        admin: Bool? = nil,
        auditor: Bool? = nil,
        blocked: Bool? = nil,
        cellphoneNumber: String? = nil,
        contactFirstName: String? = nil,
        contactId: Int? = nil,
        contactName: String? = nil,
        contactLastName: String? = nil,
        coreUserId: Int? = nil,
        email: String? = nil,
        firstName: String? = nil,
        id: Int? = nil,
        image: String? = nil,
        keyId: String? = nil,
        lastName: String? = nil,
        myFriend: Bool? = nil,
        name: String? = nil,
        notSeenDuration: Int? = nil,
        online: Bool? = nil,
        receiveEnable: Bool? = nil,
        roles: [Roles]? = nil,
        sendEnable: Bool? = nil,
        username: String? = nil,
        chatProfileVO: Profile? = nil
    ) {
        self.init(context: context)
        self.admin = admin as? NSNumber
        self.auditor = auditor as? NSNumber
        self.blocked = blocked as? NSNumber
        self.cellphoneNumber = cellphoneNumber
        self.contactFirstName = contactFirstName
        self.contactId = contactId as? NSNumber
        self.contactName = contactName
        self.contactLastName = contactLastName
        self.coreUserId = coreUserId as? NSNumber
        self.email = email
        self.firstName = firstName
        self.id = id as? NSNumber
        self.image = image
        self.keyId = keyId
        self.lastName = lastName
        self.myFriend = myFriend as? NSNumber
        self.name = name
        self.notSeenDuration = notSeenDuration as? NSNumber
        self.online = online as? NSNumber
        self.receiveEnable = receiveEnable as? NSNumber
        self.roles = roles
        self.sendEnable = sendEnable as? NSNumber
        self.username = username
        self.chatProfileVO = chatProfileVO
    }

    private enum CodingKeys: String, CodingKey {
        case admin
        case auditor
        case blocked
        case cellphoneNumber
        case contactFirstName
        case contactId
        case contactName
        case contactLastName
        case coreUserId
        case email
        case firstName
        case id
        case image
        case keyId
        case lastName
        case myFriend
        case name
        case notSeenDuration
        case online
        case receiveEnable
        case sendEnable
        case username
        case chatProfileVO
        case roles
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(admin as? Bool, forKey: .admin)
        try container.encodeIfPresent(auditor as? Bool, forKey: .auditor)
        try container.encodeIfPresent(blocked as? Bool, forKey: .blocked)
        try container.encodeIfPresent(cellphoneNumber, forKey: .cellphoneNumber)
        try container.encodeIfPresent(contactFirstName, forKey: .contactFirstName)
        try container.encodeIfPresent(contactId as? Int, forKey: .contactId)
        try container.encodeIfPresent(contactName, forKey: .contactName)
        try container.encodeIfPresent(contactLastName, forKey: .contactLastName)
        try container.encodeIfPresent(coreUserId as? Int, forKey: .coreUserId)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(id as? Int, forKey: .id)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(keyId, forKey: .keyId)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(myFriend as? Bool, forKey: .myFriend)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(notSeenDuration as? Int, forKey: .notSeenDuration)
        try container.encodeIfPresent(online as? Bool, forKey: .online)
        try container.encodeIfPresent(receiveEnable as? Bool, forKey: .receiveEnable)
        try container.encodeIfPresent(sendEnable as? Bool, forKey: .sendEnable)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(roles, forKey: .roles)
    }
}

public extension Participant {
//    class func convertParticipantToCM(participant: Participant, fromMainMethod: Bool, threadId: Int?, entity: CMParticipant? = nil) -> CMParticipant {
//        let model = entity ?? CMParticipant()
//
//        if fromMainMethod {
//            model.admin = participant.admin as NSNumber?
//            model.auditor = participant.auditor as NSNumber?
//            model.blocked = participant.blocked as NSNumber?
//            model.contactId = participant.contactId as NSNumber?
//            model.coreUserId = participant.coreUserId as NSNumber?
//            model.myFriend = participant.myFriend as NSNumber?
//            model.sendEnable = participant.sendEnable as NSNumber?
//            model.notSeenDuration = participant.notSeenDuration as NSNumber?
//            model.online = participant.online as NSNumber?
//            model.receiveEnable = participant.receiveEnable as NSNumber?
//            model.time = Int(Date().timeIntervalSince1970) as NSNumber?
//        }
//        model.id = participant.id as NSNumber?
//        model.cellphoneNumber = participant.cellphoneNumber
//        model.contactFirstName = participant.contactFirstName
//        model.contactName = participant.contactName
//        model.contactLastName = participant.contactLastName
//        model.email = participant.email
//        model.firstName = participant.firstName
//        model.image = participant.image
//        model.keyId = participant.keyId
//        model.lastName = participant.lastName
//        model.name = participant.name
//        model.roles = participant.roles
//        if let threadId = threadId {
//            model.threadId = NSNumber(value: threadId)
//        }
//        model.username = participant.username
//        model.bio = participant.chatProfileVO?.bio
//        model.metadata = participant.chatProfileVO?.metadata
//
//        return model
//    }
//
//    class func insertOrUpdate(participant: Participant, fromMainMethod: Bool = false, threadId: Int?, resultEntity: ((CMParticipant) -> Void)? = nil) {
//        if let id = participant.id, let threadId = threadId, let findedEntity = CMParticipant.crud.fetchWith(NSPredicate(format: "id == %i AND threadId == %i", id, threadId))?.first {
//            let cmParticipant = convertParticipantToCM(participant: participant, fromMainMethod: fromMainMethod, threadId: threadId, entity: findedEntity)
//            resultEntity?(cmParticipant)
//        } else {
//            CMParticipant.crud.insert { cmLinkedUserEntity in
//                let cmParticipant = convertParticipantToCM(participant: participant, fromMainMethod: fromMainMethod, threadId: threadId, entity: cmLinkedUserEntity)
//                resultEntity?(cmParticipant)
//            }
//        }
//    }
//
//    class func insertOrUpdateParicipants(participants: [Participant]?, fromMainMethod: Bool = false, threadId: Int?, resultEntity: ((CMParticipant) -> Void)? = nil) {
//        participants?.forEach { participant in
//            insertOrUpdate(participant: participant, fromMainMethod: fromMainMethod, threadId: threadId, resultEntity: resultEntity)
//        }
//    }
//
//    class func deleteParticipants(participants: [Participant]?, threadId: Int?) {
//        guard let participants = participants, let threadId = threadId else { return }
//        crud.fetchWith(NSPredicate(format: "threadId == %i", threadId))?.forEach { cmParticipant in
//            if (participants.contains { $0.id == cmParticipant.id as? Int }) {
//                crud.delete(entity: cmParticipant)
//            }
//        }
//    }
}
