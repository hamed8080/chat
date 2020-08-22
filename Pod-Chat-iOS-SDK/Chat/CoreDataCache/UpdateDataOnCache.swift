//
//  UpdateDataOnCache.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import CoreData


extension Cache {
    
    
    // MARK: - update Contact:
    /// Update CMContact Entity:
    ///
    /// - fetch CMContact and see if we already had this contact on the Cache or not
    /// - if it found one, it will update it's properties
    /// - if not, it will create an CMContact object and save it in the Cache
    ///
    /// - Parameters:
    ///     - withContactObject:  the contact model that you want to save it on cache. (Contact)
    ///
    /// - returns:
    ///     it returns the result as 'CMContact?' Model
    ///
    func updateCMContactEntity(withContactObject myContact: Contact) -> CMContact? {
        var contactToReturn: CMContact?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        if let contactId = myContact.id {
            fetchRequest.predicate = NSPredicate(format: "id == %i", contactId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMContact] {
                    if (result.count > 0) {
                        result.first!.updateObject(with: myContact)
                        if let contactLinkeUser = myContact.linkedUser {
                            result.first!.linkedUser = updateCMLinkedUserEntity(withLinkedUser: contactLinkeUser)
                        }
                        contactToReturn = result.first!
                        saveContext(subject: "Update CMContact -update existing object-")
                        
                    } else {
                        let theContactEntity = NSEntityDescription.entity(forEntityName: "CMContact", in: context)
                        let theContact = CMContact(entity: theContactEntity!, insertInto: context)
                        theContact.updateObject(with: myContact)
                        if let contactLinkeUser = myContact.linkedUser {
                            theContact.linkedUser = updateCMLinkedUserEntity(withLinkedUser: contactLinkeUser)
                        }
                        contactToReturn = theContact
                        saveContext(subject: "Update CMContact -create new object-")
                    }
                }
            } catch {
                fatalError("Error on trying to find the contact from CMContact entity")
            }
        }
        return contactToReturn
    }
    
    
    // MARK: - update UserInfo(ContactSynced):
    /// Update CMUser Entity:
    ///
    /// - fetch CMUser and see if we already had this contact on the Cache or not
    /// - if it found one, it will update it's contactSynced property
    ///
    public func updateUserContactSynced() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUser")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMUser] {
                if (result.count > 0) {
                    result.first!.contactSynced = true as NSNumber?
                    saveContext(subject: "Update UserInfo -update existing object-")
                }
            }
        } catch {
            fatalError("Error on fetching list of CMUser")
        }
    }
    
    
    // MARK: - update LinkedUser:
    /// Update CMLinkedUser Entity:
    ///
    /// - fetch CMLinkedUser and see if we already had this linkedUser on the Cache or not
    /// - if it found one, it will update it's properties
    /// - if not, it will create an CMLinkedUser object and save it in the Cache
    ///
    /// - Parameters:
    ///     - withLinkedUser:   the contact model that you want to save it on cache. (LinkedUser)
    ///
    /// - returns:
    ///     it returns the result as 'CMLinkedUser?' Model
    ///
    func updateCMLinkedUserEntity(withLinkedUser myLinkedUser: LinkedUser) -> CMLinkedUser? {
        var linkedUserToReturn: CMLinkedUser?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMLinkedUser")
        if let linkedUserId = myLinkedUser.coreUserId {
            fetchRequest.predicate = NSPredicate(format: "coreUserId == %i", linkedUserId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMLinkedUser] {
                    if (result.count > 0) {
                        result.first!.updateObject(with: myLinkedUser)
                        linkedUserToReturn = result.first!
                        saveContext(subject: "Update CMLinkedUser -update existing object-")
                    } else {
                        let theLinkedUserEntity = NSEntityDescription.entity(forEntityName: "CMLinkedUser", in: context)
                        let theLinkedUser = CMLinkedUser(entity: theLinkedUserEntity!, insertInto: context)
                        theLinkedUser.updateObject(with: myLinkedUser)
                        linkedUserToReturn = theLinkedUser
                        saveContext(subject: "Update CMLinkedUser -create new object-")
                    }
                }
            } catch {
                fatalError("Error on trying to find the linkedUser from CMLinkedUser entity")
            }
        }
        return linkedUserToReturn
    }
    
    
    
    // MARK: - update Conversation:
    /// Update CMConversation Entity:
    ///
    /// - fetch CMConversation objcets from the CMConversation Entity, and see if we already had this Conversation on the cache or not
    /// - if it found the object on the Entity, it will update the property values of it,
    /// - if not, it will create CMConversation object and save it on the Cache
    ///
    /// - Parameters:
    ///     - withConversationObject:   the conversation model that you want to save it on cache. (Conversation)
    ///
    /// - returns:
    ///     it returns the result as 'CMConversation?' Model
    ///
    func updateCMConversationEntity(withConversationObject myThread: Conversation) -> CMConversation? {
        var conversationToReturn: CMConversation?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        if let threadId = myThread.id {
            fetchRequest.predicate = NSPredicate(format: "id == %i", threadId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                    if (result.count > 0) {
                        result.first!.updateObject(with: myThread)
                        if let threadInviter = myThread.inviter {
                            result.first!.inviter = updateCMParticipantEntity(inThreadId: threadId, withParticipantsObject: threadInviter, isAdminRequest: false)
                        }
                        if let threadLastMessageVO = myThread.lastMessageVO {
                            result.first!.lastMessageVO = updateCMMessageEntity(withMessageObject: threadLastMessageVO)
                        }
                        if let pinMessage = myThread.pinMessage {
                            deleteAllPinMessageFromCMMessageEntity(onThreadId: threadId)
                            if let pin = updateCMPinMessageEntity(withObject: pinMessage) {
                                result.first!.pinMessage = pin
                            }
                        }
                        conversationToReturn = result.first!
                        
                        saveContext(subject: "Update CMConversation -update existing object-")
                    } else {
                        let conversationEntity = NSEntityDescription.entity(forEntityName: "CMConversation", in: context)
                        let conversation = CMConversation(entity: conversationEntity!, insertInto: context)
                        conversation.updateObject(with: myThread)
                        if let threadInviter = myThread.inviter {
                            conversation.inviter = updateCMParticipantEntity(inThreadId: threadId, withParticipantsObject: threadInviter, isAdminRequest: false)
                        }
                        if let threadLastMessageVO = myThread.lastMessageVO {
                            conversation.lastMessageVO = updateCMMessageEntity(withMessageObject: threadLastMessageVO)
                        }
                        if let pinMessage = myThread.pinMessage {
                            deleteAllPinMessageFromCMMessageEntity(onThreadId: threadId)
                            if let pin = updateCMPinMessageEntity(withObject: pinMessage) {
                                conversation.pinMessage = pin
                            }
                        }
                        conversationToReturn = conversation
                        
                        saveContext(subject: "Update CMConversation -create new object-")
                    }
                }
            } catch {
                fatalError("Error on trying to find the thread from CMConversation entity")
            }
        }
        return conversationToReturn
    }
    
    
    
    // MARK: - update Conversation UnreadCount:
    /// Update CMConversation UnreadCount:
    ///
    /// - fetch CMConversation objcets from the CMConversation Entity, and see if we already had this Conversation on the cache or not
    /// - if it found the object on the Entity, it will update the 'unreadCount' property value of it.
    ///
    /// - Parameters:
    ///     - withThreadId:     the thread id (Int)
    ///     - unreadCount:      update the 'unreadCount' property with this number. (Int?)
    ///     - addCount:         add this number to 'unreadCount' previous value. (Int?)
    ///
    /// - returns:
    ///     none
    ///
    func updateUnreadCountOnCMConversation(withThreadId threadId: Int, unreadCount: Int?, addCount: Int?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        fetchRequest.predicate = NSPredicate(format: "id == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                if result.count > 0 {
                    if let count = unreadCount {
                        result.first!.unreadCount = count as NSNumber
                    } else if let add = addCount {
                        let lastUnreadCount = Int(truncating: result.first!.unreadCount ?? 0)
                        result.first!.unreadCount = (lastUnreadCount + add) as NSNumber
                    }
                }
            }
        } catch {
            fatalError("Error on trying to find the thread from CMConversation entity to update unreadCount")
        }
    }
    
    
    
    // MARK: - update Participant:
    /// Update Participant Entity:
    ///
    /// - fetch the CMParticipant objcet from the CMParticipant Entity, and see if we already had this Participant object on the cache or not
    /// - if it found the object on the Entity, it will update the property values of it
    /// - if not, it will create CMParticipant object and save it on the Cache
    ///
    /// - Parameters:
    ///     - inThreadId:               the thread id (Int)
    ///     - withParticipantsObject:   the 'Participant' model that have to update it on the cache. (Participant)
    ///     - isAdminRequest:           specify if this is the result of the Admin participants or not.
    ///
    /// - returns:
    ///     it returns the result as 'CMParticipant?' Model
    ///
    func updateCMParticipantEntity(inThreadId threadId: Int, withParticipantsObject myParticipant: Participant, isAdminRequest: Bool) -> CMParticipant? {
        var participantObjectToReturn: CMParticipant?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        if let participantId = myParticipant.id {
            fetchRequest.predicate = NSPredicate(format: "id == %i AND threadId == %i", participantId, threadId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                    if (result.count > 0) {
                        result.first!.updateObject(with: myParticipant, inThreadId: threadId, isAdminRequest: isAdminRequest)
                        participantObjectToReturn = result.first!
                        saveContext(subject: "Update CMParticipant -update existing object-")
                    } else {
                        let theParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
                        let theParticipant = CMParticipant(entity: theParticipantEntity!, insertInto: context)
                        theParticipant.updateObject(with: myParticipant, inThreadId: threadId, isAdminRequest: isAdminRequest)
                        participantObjectToReturn = theParticipant
                        saveContext(subject: "Update CMParticipant -create a new object-")
                    }
                }
            } catch {
                fatalError("Error on trying to find the participant from CMParticipant entity")
            }
        }
        return participantObjectToReturn
    }
    
    
    
    // MARK: - update Message:
    /// Update Message Entity:
    ///
    /// - fetch the CMMessage objcet from the CMMessage Entity, and see if we already had this Participant object on the cache or not.
    /// - if it found the object on the Entity, it will update the property values of it
    /// - if not, it will create CMMessage object and save it on the Cache
    ///
    /// - Parameters:
    ///     - withMessageObject:   the 'Message' model that have to update it on the cache. (Message)
    ///
    /// - returns:
    ///     it returns the result as 'CMMessage?' Model
    ///
    func updateCMMessageEntity(withMessageObject myMessage: Message) -> CMMessage? {
        var messageObjectToReturn: CMMessage?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        if let messageId = myMessage.id {
            fetchRequest.predicate = NSPredicate(format: "id == %i", messageId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                    if (result.count > 0) {
                        result.first!.updateObject(with: myMessage)
                        if let messageConversation = myMessage.conversation,
                            let conversationObject = updateCMConversationEntity(withConversationObject: messageConversation) {
                            result.first!.conversation = conversationObject
                        }
                        if let messageParticipant = myMessage.participant {
                            let participantObject = updateCMParticipantEntity(inThreadId: myMessage.threadId!, withParticipantsObject: messageParticipant, isAdminRequest: false)
                            result.first!.participant = participantObject
                        }
                        
                        if let messageForwardInfo = myMessage.forwardInfo,
                            let conversation = messageForwardInfo.conversation,
                            let thId = conversation.id,
                            let msgId = myMessage.id {
                            
                            result.first!.forwardInfo = updateCMForwardInfoEntity(inThreadId: thId, withObject: messageForwardInfo, withMessageId: msgId)
                        }
                        
//                        if let messageForwardInfo = myMessage.forwardInfo {
//                            if let conversation = messageForwardInfo.conversation {
//                                if let thId = conversation.id, let msgId = myMessage.id {
//                                    result.first!.forwardInfo = updateCMForwardInfoEntity(inThreadId: thId, withObject: messageForwardInfo, withMessageId: msgId)
//                                }
//                            }
//                        }
                        if let messageReplyInfo = myMessage.replyInfo,
                            let conversation = myMessage.conversation,
                            let thId = conversation.id,
                            let msgId = myMessage.id {
                            
                            result.first!.replyInfo = updateCMReplyInfoEntity(inThreadId: thId, withObject: messageReplyInfo, withMessageId: msgId)
                        }
//                        if let messageReplyInfo = myMessage.replyInfo {
//                            result.first!.replyInfo = createCMReplyInfo(fromObject: messageReplyInfo, onThreadId: myMessage.threadId!)
////                            if let reply = updateCMReplyInfoEntity(inThreadId: myMessage.threadId!, withObject: messageReplyInfo) {
////                                result.first!.replyInfo = reply
////                            }
//                        }
                        
                        messageObjectToReturn = result.first!
                        saveContext(subject: "Update CMMessage -update existing object-")
                        
                    } else {
                        let theMessageEntity = NSEntityDescription.entity(forEntityName: "CMMessage", in: context)
                        let theMessage = CMMessage(entity: theMessageEntity!, insertInto: context)
                        theMessage.updateObject(with: myMessage)
                        if let messageConversation = myMessage.conversation,
                            let conversationObject = updateCMConversationEntity(withConversationObject: messageConversation) {
                            theMessage.conversation = conversationObject
                        }
                        if let messageParticipant = myMessage.participant,
                            let participantObject = updateCMParticipantEntity(inThreadId: myMessage.threadId!, withParticipantsObject: messageParticipant, isAdminRequest: false) {
                            theMessage.participant = participantObject
                        }
                        
                        if let messageForwardInfo = myMessage.forwardInfo,
                            let conversation = messageForwardInfo.conversation,
                            let thId = conversation.id,
                            let msgId = myMessage.id {
                            
                            theMessage.forwardInfo = updateCMForwardInfoEntity(inThreadId: thId, withObject: messageForwardInfo, withMessageId: msgId)
                        }
                        if let messageReplyInfo = myMessage.replyInfo,
                            let conversation = myMessage.conversation,
                            let thId = conversation.id,
                            let msgId = myMessage.id {
                            
                            theMessage.replyInfo = updateCMReplyInfoEntity(inThreadId: thId, withObject: messageReplyInfo, withMessageId: msgId)
                        }
                        
//                        if let messageForwardInfo = myMessage.forwardInfo {
//                            if let conversation = messageForwardInfo.conversation {
//                                if let thId = conversation.id {
//                                    theMessage.forwardInfo = createCMForwardInfo(fromObject: messageForwardInfo, onThreadId: thId)
////                                    let forward = updateCMForwardInfoEntity(inThreadId: thId, withObject: messageForwardInfo)
////                                    theMessage.forwardInfo = forward
//                                }
//                            }
//                        }
//                        if let messageReplyInfo = myMessage.replyInfo {
//                            theMessage.replyInfo = createCMReplyInfo(fromObject: messageReplyInfo, onThreadId: myMessage.threadId!)
////                            if let reply = updateCMReplyInfoEntity(inThreadId: myMessage.threadId!, withObject: messageReplyInfo) {
////                                theMessage.replyInfo = reply
////                            }
//                        }
                        
                        messageObjectToReturn = theMessage
                        saveContext(subject: "Update CMMessage -create a new object-")
                        
                    }
                }
            } catch {
                fatalError("Error on trying to find the messages from CMMessage entity")
            }
        }
        return messageObjectToReturn
    }
    
    
    // MARK: - update ReplyInfo:
    /// Update ReplyInfo Entity:
    ///
    /// - fetch the CMReplyInfo objcet from the CMReplyInfo Entity, and see if we already had this ReplyInfo object on the cache or not.
    /// - if it found the object on the Entity, it will update the property values of it
    /// - if not, it will create CMReplyInfo object and save it on the Cache
    ///
    /// - Parameters:
    ///     - inThreadId:       id of the thread that this message is on it. (Int)
    ///     - withObject:       the 'ReplyInfo' model that have to update it on the cache. (ReplyInfo)
    ///     - withMessageId:    id of the Message that has this ReplyInfo in it. (Int)
    ///
    /// - returns:
    ///     it returns the result as 'CMReplyInfo?' Model
    ///
    func updateCMReplyInfoEntity(inThreadId threadId: Int, withObject myReplyInfo: ReplyInfo, withMessageId messageId: Int) -> CMReplyInfo? {
        var replyInfoObjectToReturn: CMReplyInfo?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMReplyInfo")
        fetchRequest.predicate = NSPredicate(format: "messageId == %i", messageId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMReplyInfo] {
                if (result.count > 0) {
                    result.first!.updateObject(with: myReplyInfo, messageId: messageId)
                    if let participant = myReplyInfo.participant,
                        let participantObject = updateCMParticipantEntity(inThreadId: threadId, withParticipantsObject: participant, isAdminRequest: false) {
                        result.first!.participant = participantObject
                    }
                    replyInfoObjectToReturn = result.first
                    saveContext(subject: "Update CMReplyInfo -update existing object-")
                } else {
                    let theCMReplyInfo = NSEntityDescription.entity(forEntityName: "CMReplyInfo", in: context)
                    let theReplyInfo = CMReplyInfo(entity: theCMReplyInfo!, insertInto: context)
                    theReplyInfo.updateObject(with: myReplyInfo, messageId: messageId)
                    if let participant = myReplyInfo.participant,
                        let participantObject = updateCMParticipantEntity(inThreadId: threadId, withParticipantsObject: participant, isAdminRequest: false) {
                        theReplyInfo.participant = participantObject
                    }
                    replyInfoObjectToReturn = theReplyInfo
                    saveContext(subject: "Update CMReplyInfo -create a new object-")
                }
            }
        } catch {
            fatalError("Error on trying to find the ReplyInfo from CMReplyInfo entity")
        }
        return replyInfoObjectToReturn
    }
    

    // MARK: - update ForwardInfo:
    /// Update ForwardInfo Entity:
    ///
    /// - fetch the CMForwardInfo objcet from the CMForwardInfo Entity, and see if we already had this ForwardInfo object on the cache or not.
    /// - if it found the object on the Entity, it will update the property values of it
    /// - if not, it will create CMForwardInfo object and save it on the Cache
    ///
    /// - Parameters:
    ///     - inThreadId:       id of the thread that this message is on it. (Int)
    ///     - withObject:       the 'ForwardInfo' model that have to update it on the cache. (ForwardInfo)
    ///     - withMessageId:    id of the Message that has this ForwardInfo in it. (Int)
    ///
    /// - returns:
    ///     it returns the result as 'CMForwardInfo?' Model
    ///
    func updateCMForwardInfoEntity(inThreadId threadId: Int, withObject myForwardInfo: ForwardInfo, withMessageId messageId: Int) -> CMForwardInfo? {
        var forwardInfoObjectToReturn: CMForwardInfo?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMForwardInfo")
        fetchRequest.predicate = NSPredicate(format: "messageId == %i", messageId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMForwardInfo] {
                if (result.count > 0) {
                    if let participant = myForwardInfo.participant,
                        let participantObject = updateCMParticipantEntity(inThreadId: threadId, withParticipantsObject: participant, isAdminRequest: false) {
                        result.first!.participant = participantObject
                    }
                    if let conversation = myForwardInfo.conversation,
                        let conversationObject = updateCMConversationEntity(withConversationObject: conversation) {
                        result.first!.conversation = conversationObject
                    }
                    forwardInfoObjectToReturn = result.first
                    saveContext(subject: "Update CMForwardInfo -update existing object-")
                } else {
                    let theCMForwardInfo = NSEntityDescription.entity(forEntityName: "CMForwardInfo", in: context)
                    let theForwardInfo = CMForwardInfo(entity: theCMForwardInfo!, insertInto: context)
                    theForwardInfo.messageId = messageId as NSNumber?
                    if let participant = myForwardInfo.participant,
                        let participantObject = updateCMParticipantEntity(inThreadId: threadId, withParticipantsObject: participant, isAdminRequest: false) {
                        theForwardInfo.participant = participantObject
                    }
                    if let conversation = myForwardInfo.conversation,
                        let conversationObject = updateCMConversationEntity(withConversationObject: conversation) {
                        theForwardInfo.conversation = conversationObject
                    }
                    forwardInfoObjectToReturn = theForwardInfo
                    saveContext(subject: "Update CMForwardInfo -create a new object-")
                }
            }
        } catch {
            fatalError("Error on trying to find the ForwardInfo from CMForwardInfo entity")
        }
        return forwardInfoObjectToReturn
    }
    
    
//    private func createCMReplyInfo(fromObject: ReplyInfo, onThreadId: Int) -> CMReplyInfo {
//        let theCMReplyInfo = NSEntityDescription.entity(forEntityName: "CMReplyInfo", in: context)
//        let theReplyInfo = CMReplyInfo(entity: theCMReplyInfo!, insertInto: context)
//        theReplyInfo.updateObject(with: fromObject)
//        if let participantObject = fromObject.participant {
//            if let participantObject = updateCMParticipantEntity(inThreadId: onThreadId, withParticipantsObject: participantObject, isAdminRequest: false) {
//                theReplyInfo.participant = participantObject
//            }
//        }
//        return theReplyInfo
//    }
//
//    private func createCMForwardInfo(fromObject: ForwardInfo, onThreadId: Int) -> CMForwardInfo {
//        let theCMForwardInfo = NSEntityDescription.entity(forEntityName: "CMForwardInfo", in: context)
//        let theForwardInfo = CMForwardInfo(entity: theCMForwardInfo!, insertInto: context)
//        if let theParticipantObject = fromObject.participant {
//            if let participantObject = updateCMParticipantEntity(inThreadId: onThreadId, withParticipantsObject: theParticipantObject, isAdminRequest: false) {
//                theForwardInfo.participant = participantObject
//            }
//        }
//        if let theConversationObject = fromObject.conversation {
//            if let conversationObject = updateCMConversationEntity(withConversationObject: theConversationObject) {
//                theForwardInfo.conversation = conversationObject
//            }
//        }
//        return theForwardInfo
//    }
    
    
    // MARK: - update PinMessage
    /// Update PinMessage Entity:
    ///
    /// - fetch the CMPinMessage objcet from the CMForwardInfo Entity, and see if we already had this PinUnpinMessage object on the cache or not.
    /// - if it found the object on the Entity, it will update the property values of it
    /// - if not, it will create CMPinMessage object and save it on the Cache
    ///
    /// - Parameters:
    ///     - withObject:       the 'PinUnpinMessage' model that have to update it on the cache. (PinUnpinMessage)
    ///
    /// - returns:
    ///     it returns the result as 'CMPinMessage?' Model
    ///
    func updateCMPinMessageEntity(withObject myPinMessage: PinUnpinMessage) -> CMPinMessage? {
        var pinMessageObjectToReturn: CMPinMessage?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMPinMessage")
        fetchRequest.predicate = NSPredicate(format: "messageId == %i", myPinMessage.messageId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMPinMessage] {
                if (result.count > 0) {
                    result.first!.updateObject(with: myPinMessage)
                    pinMessageObjectToReturn = result.first
                    saveContext(subject: "Update CMPinMessage -update existing object-")
                } else {
                    let theCMPinMessage = NSEntityDescription.entity(forEntityName: "CMPinMessage", in: context)
                    let thePinMessage = CMPinMessage(entity: theCMPinMessage!, insertInto: context)
                    thePinMessage.updateObject(with: myPinMessage)
                    pinMessageObjectToReturn = thePinMessage
                    saveContext(subject: "Update CMPinMessage -create a new object-")
                }
            }
        } catch {
            fatalError("Error on trying to find the PinUnpinMessage from CMPinMessage entity")
        }
        return pinMessageObjectToReturn
    }
    
    
    
    // MARK: - update MessageGap:
    /// Update MessageGap Entity:
    ///
    /// - fetch MessageGaps where their threadId is equal to input 'threadId' \
    ///     - check if we found any object on the MessageGaps that is waiting for a messageId (its previousId property) that we have here on 'messageId'
    ///         - if yes -> delete this object from MessageGaps Entity
    ///     - check if we have previouse message of this message on the gap or not
    ///     - check if we found the message on the MessageGaps, we will update its values
    ///     - otherwise we will create a MessageGaps object and assing input values to this object
    ///
    /// - Parameters:
    ///     - threadId:         id of the thread that this message is on it. (Int)
    ///     - withMessageId:    id of the message. (Int)
    ///     - withPreviousId:   previous id of the message. (Int)
    ///
    /// - returns:
    ///     none
    ///
    func updateMessageGapEntity(inThreadId threadId: Int, withMessageId messageId: Int, withPreviousId previousId: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageGaps")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [MessageGaps] {
                for item in result {
                    if ((item.messageId as? Int) == messageId) {
                        item.updateObject(onThreadId: threadId, withMessageId: messageId, withPreviousId: previousId)
                        saveContext(subject: "Update MessageGaps -update existing object-")
                    } else {
                        let theMessageGapsEntity = NSEntityDescription.entity(forEntityName: "MessageGaps", in: context)
                        let theMessageGap = MessageGaps(entity: theMessageGapsEntity!, insertInto: context)
                        theMessageGap.updateObject(onThreadId: threadId, withMessageId: messageId, withPreviousId: previousId)
                        saveContext(subject: "Update MessageGaps -create new object-")
                    }
                }
            }
        } catch {
            fatalError("Error on trying to find MessageGaps")
        }
        
    }
    
    
    
    // MARK: - update AllMessageGap:
    /// Update AllMessageGap Entity:
    ///
    /// - delete all messageGaps on threadId
    /// - fetch all messages with 'threadId' Input
    /// - lopp through it messages.
    ///     - if we found any message that it's previousId is not in the array, add it to the "gaps" array, to sendIt to 'saveMessageGap'
    ///
    /// - Parameters:
    ///     - inThreadId:   id of the thread. (Int)
    ///
    /// - returns:
    ///     none
    ///
    func updateAllMessageGapEntity(inThreadId threadId: Int) {
        deleteAllMessageGaps(inThreadId: threadId)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                
                var gaps: (msgIds: [Int], prevIds: [Int]) = ([], [])
                for message in result {
                    for item in result {
                        var foundPrevious = false
                        if (message.previousId == item.id) {
                            foundPrevious = true
                        }
                        if !foundPrevious {
                            gaps.msgIds.append(message.id as! Int)
                            if let pId = message.previousId as? Int {
                                gaps.prevIds.append(pId)
                            } else {
                                gaps.prevIds.append(0)
                            }
                        }
                    }
                }
                
                for (index, _) in gaps.msgIds.enumerated() {
                    updateMessageGapEntity(inThreadId: threadId, withMessageId: gaps.msgIds[index], withPreviousId: gaps.prevIds[index])
                }
                
            }
        } catch {
            fatalError("Error on trying to find CMMessage when trying to Update All MessageGap")
        }
            
    }
 
    
}

