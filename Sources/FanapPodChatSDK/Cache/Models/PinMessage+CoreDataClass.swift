//
//  PinMessage+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class PinMessage: NSManagedObject, Codable {
    var sender: Participant?

    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try container.decode(Int.self, forKey: .messageId) as NSNumber?
        notifyAll = (try container.decodeIfPresent(Bool.self, forKey: .notifyAll) ?? false) as NSNumber?
        text = try container.decodeIfPresent(String.self, forKey: .text)
        sender = try container.decodeIfPresent(Participant.self, forKey: .sender)
        time = try container.decodeIfPresent(Int.self, forKey: .time) as? NSNumber
    }
}

public extension PinMessage {
    private enum CodingKeys: String, CodingKey {
        case messageId
        case notifyAll
        case text
        case sender
        case time
    }

    convenience init(
        context: NSManagedObjectContext,
        messageId: Int,
        notifyAll: Bool,
        text: String?,
        sender: Participant?,
        time: Int?
    ) {
        self.init(context: context)
        self.messageId = messageId as NSNumber?
        self.notifyAll = notifyAll as NSNumber?
        self.text = text
        self.sender = sender
        self.time = time as NSNumber?
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(messageId as? Int, forKey: .messageId)
        try container.encodeIfPresent(notifyAll as? Bool, forKey: .notifyAll)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encodeIfPresent(time as? Int, forKey: .time)
        try container.encodeIfPresent(sender, forKey: .sender)
    }
}

// public extension CMPinMessage {
//    class func insertOrUpdate(pinMessage: PinUnpinMessage, resultEntity: ((CMPinMessage) -> Void)? = nil) {
//        if let findedEntity = CMPinMessage.crud.find(keyWithFromat: "messageId == %i", value: pinMessage.messageId) {
//            let cmPinMessage = convertPinMessageToCM(pinMessage: pinMessage, entity: findedEntity)
//            resultEntity?(cmPinMessage)
//        } else {
//            CMPinMessage.crud.insert { cmPinMessageEntity in
//                let cmPinMessage = convertPinMessageToCM(pinMessage: pinMessage, entity: cmPinMessageEntity)
//                resultEntity?(cmPinMessage)
//            }
//        }
//    }
//
//    class func pinMessage(pinMessage: PinUnpinMessage, threadId: Int?) {
//        guard let threadId = threadId else { return }
//
//        // 1-unpin old message if exist
//        unpinMessage(pinMessage: pinMessage, threadId: threadId)
//        // 2-set new pinMessage relation to threadPinMessage property
//        let thread = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId)
//        insertOrUpdate(pinMessage: pinMessage) { resultEntity in
//            thread?.pinMessage = resultEntity
//        }
//        // 3-set true Message Model
//        if let message = CMMessage.crud.find(keyWithFromat: "id == %id", value: pinMessage.messageId)?.getCodable() {
//            CMMessage.insertOrUpdate(message: message, conversation: thread) { resultEntity in
//                resultEntity.pinned = true
//            }
//        }
//    }
//
//    class func unpinMessage(pinMessage: PinUnpinMessage, threadId: Int?) {
//        guard let threadId = threadId else { return }
//        let thread = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId)
//        insertOrUpdate(pinMessage: pinMessage) { _ in
//            thread?.pinMessage = nil
//        }
//        if let message = CMMessage.crud.find(keyWithFromat: "id == %id", value: pinMessage.messageId)?.getCodable() {
//            CMMessage.insertOrUpdate(message: message, conversation: thread) { resultEntity in
//                resultEntity.pinned = false
//            }
//        }
//    }
// }
