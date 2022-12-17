//
// CMParticipant+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public extension CMParticipant {
    static let crud = CoreDataCrud<CMParticipant>(entityName: "CMParticipant")

    func getCodable() -> Participant {
        Participant(admin: admin as? Bool,
                    auditor: auditor as? Bool,
                    blocked: blocked as? Bool,
                    cellphoneNumber: cellphoneNumber,
                    contactFirstName: contactFirstName,
                    contactId: contactId as? Int,
                    contactName: contactName,
                    contactLastName: contactLastName,
                    coreUserId: coreUserId as? Int,
                    email: email,
                    firstName: firstName,
                    id: id as? Int,
                    image: image,
                    keyId: keyId,
                    lastName: lastName,
                    myFriend: myFriend as? Bool,
                    name: name,
                    notSeenDuration: notSeenDuration as? Int,
                    online: online as? Bool,
                    receiveEnable: receiveEnable as? Bool,
                    roles: roles,
                    sendEnable: sendEnable as? Bool,
                    username: username,
                    chatProfileVO: Profile(bio: bio, metadata: metadata))
    }

    class func convertParticipantToCM(participant: Participant, fromMainMethod: Bool, threadId: Int?, entity: CMParticipant? = nil) -> CMParticipant {
        let model = entity ?? CMParticipant()

        if fromMainMethod {
            model.admin = participant.admin as NSNumber?
            model.auditor = participant.auditor as NSNumber?
            model.blocked = participant.blocked as NSNumber?
            model.contactId = participant.contactId as NSNumber?
            model.coreUserId = participant.coreUserId as NSNumber?
            model.myFriend = participant.myFriend as NSNumber?
            model.sendEnable = participant.sendEnable as NSNumber?
            model.notSeenDuration = participant.notSeenDuration as NSNumber?
            model.online = participant.online as NSNumber?
            model.receiveEnable = participant.receiveEnable as NSNumber?
            model.time = Int(Date().timeIntervalSince1970) as NSNumber?
        }
        model.id = participant.id as NSNumber?
        model.cellphoneNumber = participant.cellphoneNumber
        model.contactFirstName = participant.contactFirstName
        model.contactName = participant.contactName
        model.contactLastName = participant.contactLastName
        model.email = participant.email
        model.firstName = participant.firstName
        model.image = participant.image
        model.keyId = participant.keyId
        model.lastName = participant.lastName
        model.name = participant.name
        model.roles = participant.roles
        if let threadId = threadId {
            model.threadId = NSNumber(value: threadId)
        }
        model.username = participant.username
        model.bio = participant.chatProfileVO?.bio
        model.metadata = participant.chatProfileVO?.metadata

        return model
    }

    class func insertOrUpdate(participant: Participant, fromMainMethod: Bool = false, threadId: Int?, resultEntity: ((CMParticipant) -> Void)? = nil) {
        if let id = participant.id, let threadId = threadId, let findedEntity = CMParticipant.crud.fetchWith(NSPredicate(format: "id == %i AND threadId == %i", id, threadId))?.first {
            let cmParticipant = convertParticipantToCM(participant: participant, fromMainMethod: fromMainMethod, threadId: threadId, entity: findedEntity)
            resultEntity?(cmParticipant)
        } else {
            CMParticipant.crud.insert { cmLinkedUserEntity in
                let cmParticipant = convertParticipantToCM(participant: participant, fromMainMethod: fromMainMethod, threadId: threadId, entity: cmLinkedUserEntity)
                resultEntity?(cmParticipant)
            }
        }
    }

    class func insertOrUpdate(participant: Participant, resultEntity: ((CMParticipant) -> Void)? = nil) {
        if let id = participant.id, let findedEntity = CMParticipant.crud.fetchWith(NSPredicate(format: "id == %i", id))?.first {
            let cmParticipant = convertParticipantToCM(participant: participant, fromMainMethod: false, threadId: nil, entity: findedEntity)
            resultEntity?(cmParticipant)
        } else {
            CMParticipant.crud.insert { cmLinkedUserEntity in
                let cmParticipant = convertParticipantToCM(participant: participant, fromMainMethod: false, threadId: nil, entity: cmLinkedUserEntity)
                resultEntity?(cmParticipant)
            }
        }
    }

    class func insertOrUpdateParicipants(participants: [Participant]?, fromMainMethod: Bool = false, threadId: Int?, resultEntity: ((CMParticipant) -> Void)? = nil) {
        participants?.forEach { participant in
            insertOrUpdate(participant: participant, fromMainMethod: fromMainMethod, threadId: threadId, resultEntity: resultEntity)
        }
    }

    class func deleteParticipants(participants: [Participant]?, threadId: Int?) {
        guard let participants = participants, let threadId = threadId else { return }
        crud.fetchWith(NSPredicate(format: "threadId == %i", threadId))?.forEach { cmParticipant in
            if (participants.contains { $0.id == cmParticipant.id as? Int }) {
                crud.delete(entity: cmParticipant)
            }
        }
    }
}
