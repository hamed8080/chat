//
// CasheFactory.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class CacheFactory {
    public enum ReadCacheType {
        case getCashedContacts(_ req: ContactsRequest?)
        case getThreads(_ req: ThreadsRequest)
        case getBlockedUsers
        case getThreadParticipants(_ req: ThreadParticipantsRequest)
        case cureentUserRoles(_ threadId: Int)
        case userInfo
        case allUnreadCount
        case mentions
        case getHistory(_ req: GetHistoryRequest)
        case getTextNotSentRequests(_ threadId: Int)
        case editMessageRequests(_ threadId: Int)
        case forwardMessageRequests(_ fromThreadId: Int)
        case fileMessageRequests(_ threadId: Int)
        case threadAdmins(_ threadId: Int)
        case threadParticipants(_ threadId: Int, _ count: Int, _ offset: Int, _ ascending: Bool)
        case pinThreads
        case newThreads(_ count: Int, _ offset: Int)
        case phoneContacts
        case allThreads
        case getAssistants(_ count: Int, _ offset: Int)
        case getBlockedAssistants(_ count: Int, _ offset: Int)
        case getMutualGroups(_ req: MutualGroupsRequest)
        case tags
    }

    public enum WriteCacheType {
        case deleteAllCacheData
        case casheContacts(_ contacts: [Contact])
        case threads(_ threads: [Conversation])
        case getBlockedUsers
        case participants(_ participants: [Participant]?, _ threadId: Int?)
        case removeParticipants(participants: [Participant]?, threadId: Int?)
        case leaveThread(_ threadId: Int)
        case currentUserRoles(_ roles: [Roles], _ threadId: Int?)
        case userInfo(_ user: User)
        case pinMessage(_ pinMessage: PinUnpinMessage, _ threadId: Int?)
        case unpinMessage(_ unpinMessage: PinUnpinMessage, _ threadId: Int?)
        case clearAllHistory(_ threadId: Int)
        case deleteMessage(_ threadId: Int, messageId: Int)
        case deleteMessages(_ threadId: Int, messageIds: [Int])
        case sendTxetMessageQueue(_ req: SendTextMessageRequest)
        case deleteSendTxetMessageQueue(_ uniqueId: String)
        case message(_ message: Message)
        case deleteQueue(_ uniqueId: String)
        case editMessageQueue(_ req: EditMessageRequest)
        case deleteEditMessageQueue(_ message: Message)
        case forwardMessageQueue(_: ForwardMessageRequest)
        case deleteForwardMessageQueue(_ uniqueId: String)
        case deleteFileMessageQueue(_ uniqueId: String)
        case sendFileMessageQueue(_ req: UploadFileRequest, _ textMessage: SendTextMessageRequest? = nil)
        case deleteAllUser
        case deleteContacts(_ contactIds: [Int])
        case deleteThreads(_ threadIds: [Int])
        case deleteAllContacts
        case deleteAllThreads
        case deleteAllMessage
        case syncedContacts
        case deleteWaitTextMessage(_ uniqueId: String)
        case deleteEditTextMessage(_ uniqueId: String)
        case deleteForwardMessage(_ uniqueId: String)
        case deleteWaitFileMessage(_ uniqueId: String)
        case setThreadUnreadCount(_ threadId: Int, _ unreadCount: Int)
        case insertOrUpdateAssistants(_ assistants: [Assistant])
        case deleteAssistants(_ assistant: [Assistant])
        case mutualGroups(_ threads: [Conversation], _ req: MutualGroupsRequest)
        case muteUnmuteThread(_ threadId: Int)
        case pinUnpinThread(_ threadId: Int)
        case tags(_ tags: [Tag])
        case tagParticipants(_ tagParticipants: [TagParticipant], _ tagId: Int)
        case deleteTag(_ tag: Tag)
        case deleteTagParticipants(_ tagParticipants: [TagParticipant])
        case archiveUnarchiveAhread(_ isArchive: Bool, _ threadId: Int)
        case lastThreadMessageUpdated(_ threadId: Int, _ lastMessage: Message)
    }

    public class func get(useCache: Bool = false, cacheType: ReadCacheType, completion: OnChatResponseType? = nil) {
        if Chat.sharedInstance.config?.enableCache == true, useCache == true {
            switch cacheType {
            case let .getCashedContacts(_: req):
                let contacts = CMContact.getContacts(req: req)
                completion?(.init(cacheResponse: contacts))
            case .getBlockedUsers:
                // completion?(.init(result: nil, cacheResponse: CMBlocked.crud.getAll().map{$0.convertCMObjectToObject()}, error: nil))
                break
            case let .getThreads(_: req):
                let threads = CMConversation.getThreads(req: req)
                completion?(.init(cacheResponse: threads))
            case let .getThreadParticipants(_: req):
                let predicate: NSPredicate = req.admin ? .init(format: "threadId == %i AND admin == %@", req.threadId, NSNumber(value: true)) : .init(format: "threadId == %i", req.threadId)
                let cmParticipants = CMParticipant.crud.fetchWithOffset(count: req.count, offset: req.offset, predicate: predicate)
                let paricipants = cmParticipants.map { $0.getCodable() }
                completion?(.init(cacheResponse: paricipants))
            case let .cureentUserRoles(_: threadId):
                let roles = CMCurrentUserRoles.crud.fetchWith(NSPredicate(format: "threadId == %i", threadId))
                completion?(.init(cacheResponse: roles?.first?.getCodable()))
            case .userInfo:
                let user = CMUser.crud.getAll().first?.getCodable()
                completion?(.init(cacheResponse: user))
            case .allUnreadCount:
                let allUnreadCount = CMConversation.crud.getAll().compactMap { $0.unreadCount as? Int ?? 0 }.reduce(0, +)
                completion?(.init(cacheResponse: allUnreadCount))
            case .mentions:
                let mentions = CMMessage.crud.fetchWith(NSPredicate(format: "mentioned == %@", NSNumber(value: true)))?.map { $0.getCodable() }
                completion?(.init(cacheResponse: mentions))
            case let .getHistory(_: req):
                let fetchRequest = CMMessage.fetchRequestWithGetHistoryRequest(req: req)
                let messages = CMMessage.crud.fetchWith(fetchRequest)?.map { $0.getCodable() }
                completion?(.init(cacheResponse: messages))
            case let .getTextNotSentRequests(_: threadId):
                let requests = QueueOfTextMessages.crud.fetchWith(NSPredicate(format: "threadId == %i", threadId))?.compactMap { $0.getCodable() }
                completion?(.init(cacheResponse: requests))
            case let .editMessageRequests(_: threadId):
                let requests = QueueOfEditMessages.crud.fetchWith(NSPredicate(format: "threadId == %i", threadId))?.compactMap { $0.getCodable() }
                completion?(.init(cacheResponse: requests))
            case let .forwardMessageRequests(_: fromThreadId):
                let requests = QueueOfForwardMessages.crud.fetchWith(NSPredicate(format: "fromThreadId == %i", fromThreadId))?.compactMap { $0.getCodable() }
                completion?(.init(cacheResponse: requests))
            case let .fileMessageRequests(_: threadId):
                let requests = QueueOfFileMessages.crud.fetchWith(NSPredicate(format: "threadId == %i", threadId))?.compactMap { $0.getCodable() }
                completion?(.init(cacheResponse: requests))
            case let .threadAdmins(_: threadId):
                let admins = CMParticipant.crud.fetchWith(NSPredicate(format: "threadId == %i", threadId))?.filter { $0.roles != nil }
                completion?(.init(cacheResponse: admins))
            case let .threadParticipants(_: threadId, _: count, _: offset, _: ascending):
                let nameSort = NSSortDescriptor(key: "contactName", ascending: ascending)
                let lastNameSort = NSSortDescriptor(key: "lastName", ascending: ascending)
                let firstNameSort = NSSortDescriptor(key: "firstName", ascending: ascending)
                let sorts = [nameSort, lastNameSort, firstNameSort]
                let participants = CMParticipant.crud.fetchWithOffset(count: count, offset: offset, predicate: NSPredicate(format: "threadId == %i", threadId), sortDescriptor: sorts)
                completion?(.init(cacheResponse: participants))
            case .pinThreads:
                let pinThredas = CMConversation.crud.fetchWith(NSPredicate(format: "pin == %@", NSNumber(value: true)))
                completion?(.init(cacheResponse: pinThredas))
            case let .newThreads(_: count, _: offset):
                let threads = CMConversation.crud.fetchWithOffset(count: count, offset: offset, predicate: NSPredicate(format: "unreadCount > %i", 0))
                completion?(.init(cacheResponse: threads))
            case .phoneContacts:
                let phoneContacts = PhoneContact.crud.getAll()
                completion?(.init(cacheResponse: phoneContacts))
            case .allThreads:
                let threads = CMConversation.crud.getAll()
                completion?(.init(cacheResponse: threads))
            case let .getAssistants(_: count, _: offset):
                let assistants = CMAssistant.crud.fetchWithOffset(count: count, offset: offset, predicate: nil)
                completion?(.init(cacheResponse: assistants.map { $0.getCodable() }))
            case let .getBlockedAssistants(_: count, _: offset):
                let assistants = CMAssistant.crud.fetchWithOffset(count: count, offset: offset, predicate: NSPredicate(format: "block == %@", NSNumber(value: true)))
                completion?(.init(cacheResponse: assistants.map { $0.getCodable() }))
            case let .getMutualGroups(_: req):
                let conversations = CMMutualGroup.getMutualGroups(req)
                completion?(.init(cacheResponse: conversations))
            case .tags:
                let tags = CMTag.crud.getAll()
                completion?(.init(cacheResponse: tags.map { $0.getCodable() }))
            }
        }
    }

    public class func write(cacheType: WriteCacheType) {
        if Chat.sharedInstance.config?.enableCache == true {
            switch cacheType {
            case let .casheContacts(contacts: contacts):
                CMContact.insertOrUpdate(contacts: contacts)
            case .getBlockedUsers:
                break
            case let .threads(_: threads):
                CMConversation.insertOrUpdate(conversations: threads)
            case let .participants(_: participants, _: threadId):
                CMParticipant.insertOrUpdateParicipants(participants: participants, fromMainMethod: true, threadId: threadId)
            case let .removeParticipants(_: participants, _: threadId):
                CMParticipant.deleteParticipants(participants: participants, threadId: threadId)
            case let .leaveThread(_: threadId):
                CMParticipant.crud.deleteWith(predicate: NSPredicate(format: "threadId == %i", threadId))
                CMConversation.crud.deleteWith(predicate: NSPredicate(format: "id == %i", threadId))
            case let .currentUserRoles(_: roles, _: threadId):
                if let threadId = threadId {
                    CMCurrentUserRoles.insertOrUpdate(roles: roles, threadId: threadId)
                }
            case let .userInfo(_: user):
                CMUser.insertOrUpdate(user: user, resultEntity: nil)
            case let .pinMessage(_: pinMessage, _: threadId):
                CMPinMessage.pinMessage(pinMessage: pinMessage, threadId: threadId)
            case let .unpinMessage(_: unpinMessage, _: threadId):
                CMPinMessage.unpinMessage(pinMessage: unpinMessage, threadId: threadId)
            case let .clearAllHistory(_: threadId):
                CMMessage.crud.deleteWith(predicate: NSPredicate(format: "threadId == %i", threadId))
            case let .deleteMessage(_: threadId, _: messageId):
                CMMessage.crud.deleteEntityWithPredicate(predicate: NSPredicate(format: "threadId == %i AND id == %i", threadId, messageId))
            case let .deleteMessages(_: threadId, _: messageIds):
                CMMessage.crud.fetchWith(NSPredicate(format: "threadId == %i AND id IN %@", threadId, messageIds))?.forEach { entity in
                    CMMessage.crud.delete(entity: entity)
                }
            case let .sendTxetMessageQueue(_: req):
                QueueOfTextMessages.insert(request: req)
            case let .deleteSendTxetMessageQueue(_: uniqueId):
                QueueOfTextMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
            case let .message(_: message):
                CMMessage.insertOrUpdate(message: message)
            case let .deleteQueue(_: uniqueId):
                QueueOfTextMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
                QueueOfEditMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
                QueueOfForwardMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueIds CONTAINS[cd] %@", uniqueId))
                QueueOfFileMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
            case let .editMessageQueue(_: req):
                QueueOfEditMessages.insert(request: req)
            case let .deleteEditMessageQueue(_: message):
                guard let messageId = message.id, let threadId = message.conversation?.id else { return }
                QueueOfEditMessages.crud.deleteWith(predicate: NSPredicate(format: "messageId == %i AND threadId == %i", messageId, threadId))
            case let .forwardMessageQueue(_: req):
                QueueOfForwardMessages.insert(request: req)
            case let .deleteForwardMessageQueue(_: uniqueId):
                QueueOfForwardMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
            case let .sendFileMessageQueue(_: req, _: textMessage):
                QueueOfFileMessages.insert(request: req, textMessage: textMessage)
            case let .deleteFileMessageQueue(_: uniqueId):
                QueueOfFileMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
            case .deleteAllUser:
                CMUser.crud.deleteAll()
            case let .deleteContacts(_: contactIds):
                CMContact.crud.deleteWith(predicate: NSPredicate(format: "id IN %@", contactIds))
            case let .deleteThreads(_: threadIds):
                CMConversation.crud.deleteWith(predicate: NSPredicate(format: "id IN %@", threadIds))
            case .deleteAllContacts:
                CMContact.crud.deleteAll()
            case .deleteAllThreads:
                CMConversation.crud.deleteAll()
            case .deleteAllMessage:
                CMMessage.crud.deleteAll()
            case .deleteAllCacheData:
                CMUser.crud.deleteAll()
                CMContact.crud.deleteAll()
                PhoneContact.crud.deleteAll()
                CMConversation.crud.deleteAll()
                CMMutualGroup.crud.deleteAll()
                CMForwardInfo.crud.deleteAll()
                CMLinkedUser.crud.deleteAll()
                CMMessage.crud.deleteAll()
                CMParticipant.crud.deleteAll()
                CMReplyInfo.crud.deleteAll()
                CMPinMessage.crud.deleteAll()
                QueueOfTextMessages.crud.deleteAll()
                QueueOfFileMessages.crud.deleteAll()
                QueueOfEditMessages.crud.deleteAll()
                QueueOfForwardMessages.crud.deleteAll()
                CMAssistant.crud.deleteAll()
                CacheFileManager.sharedInstance.deleteAllFiles()
                CacheFileManager.sharedInstance.deleteAllImages()
                CMTag.crud.deleteAll()
                CMTagParticipant.crud.deleteAll()
                CMFile.crud.deleteAll()
                CMImage.crud.deleteAll()
                CMUserRole.crud.deleteAll()
                PhoneContact.crud.deleteAll()
            case .syncedContacts:
                CMUser.crud.getAll().forEach { user in
                    user.contactSynced = NSNumber(value: true)
                }
            case let .deleteWaitTextMessage(_: uniqueId):
                QueueOfTextMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
            case let .deleteEditTextMessage(_: uniqueId):
                QueueOfEditMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
            case let .deleteForwardMessage(_: uniqueId):
                QueueOfForwardMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
            case let .deleteWaitFileMessage(_: uniqueId):
                QueueOfFileMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
            case let .setThreadUnreadCount(_: threadId, _: unreadCount):
                if let conversation = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId) {
                    conversation.unreadCount = NSNumber(value: unreadCount)
                }
            case let .insertOrUpdateAssistants(_: assistants):
                CMAssistant.insertOrUpdate(assistants: assistants)
            case let .deleteAssistants(_: assistants):
                assistants.forEach { assistant in
                    CMAssistant.crud.deleteWith(predicate: NSPredicate(format: "inviteeId == %i", assistant.participant?.id ?? -1))
                }
            case let .mutualGroups(_: conversations, _: req):
                CMMutualGroup.insertOrUpdate(conversations: conversations, req: req)
            case let .muteUnmuteThread(_: threadId):
                if let conversation = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId) {
                    let isMute = !((conversation.mute as? Bool) ?? false)
                    conversation.mute = NSNumber(booleanLiteral: isMute)
                }
            case let .pinUnpinThread(_: threadId):
                if let conversation = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId) {
                    let isPin = !((conversation.pin as? Bool) ?? false)
                    conversation.pin = NSNumber(booleanLiteral: isPin)
                }
            case let .tags(_: tags):
                CMTag.insertOrUpdate(tags: tags)
            case let .tagParticipants(_: tagParticipants, _: tagId):
                tagParticipants.forEach { tagParticipant in
                    CMTagParticipant.insertOrUpdate(tagParticipant: tagParticipant, tagId: tagId) { tagParticipant in
                        CMTag.addParticipant(tagId: tagId, tagParticipant: tagParticipant)
                    }
                }
            case let .deleteTag(_: tag):
                CMTag.crud.deleteWith(predicate: NSPredicate(format: "id == %i", tag.id))
                CMTagParticipant.crud.deleteWith(predicate: NSPredicate(format: "tagId == %i", tag.id))
            case let .deleteTagParticipants(_: tagParticipants):
                CMTagParticipant.crud.deleteWith(predicate: NSPredicate(format: "id IN %@", tagParticipants.map(\.id)))
            case let .archiveUnarchiveAhread(_: isArchive, _: threadId):
                if let conversation = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId) {
                    conversation.isArchive = NSNumber(booleanLiteral: isArchive)
                }
            case let .lastThreadMessageUpdated(_: threadId, _: lastMessage):
                if let messageId = lastMessage.id {
                    let req = NSPredicate(format: "id == %i AND threadId == %i", messageId, threadId)
                    if let lastMessageEntity = CMMessage.crud.fetchWith(req)?.first {
                        lastMessageEntity.conversation?.lastMessage = lastMessageEntity.message
                        lastMessageEntity.conversation?.lastMessageVO = lastMessageEntity
                    }
                }
            }
        }
    }

    public class func save() {        
        PSM.shared.save()
    }
}
