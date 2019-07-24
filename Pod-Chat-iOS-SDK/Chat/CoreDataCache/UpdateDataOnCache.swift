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
    
    /*
     * Update CMContact Entity:
     *
     * -> fetch CMContact and see if we already had this contact on the Cache or not
     * -> if we found one, we will update it's properties
     * -> if not, we will create an CMContact object and save it in the Cache
     *
     *  + Access:   Private
     *  + Inputs:
     *      - withContactObject:    Contact
     *  + Outputs:
     *      - CMContact?
     *
     */
    func updateCMContactEntity(withContactObject myContact: Contact) -> CMContact? {
        var contactToReturn: CMContact?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        if let contactId = myContact.id {
            fetchRequest.predicate = NSPredicate(format: "id == %i", contactId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMContact] {
                    if (result.count > 0) {
                        result.first!.blocked           = myContact.blocked as NSNumber?
                        result.first!.cellphoneNumber   = myContact.cellphoneNumber
                        result.first!.email             = myContact.email
                        result.first!.firstName         = myContact.firstName
                        result.first!.hasUser           = myContact.hasUser as NSNumber?
                        result.first!.id                = myContact.id as NSNumber?
                        result.first!.image             = myContact.image
                        result.first!.lastName          = myContact.lastName
                        result.first!.notSeenDuration   = myContact.notSeenDuration as NSNumber?
                        result.first!.uniqueId          = myContact.uniqueId
                        result.first!.userId            = myContact.userId as NSNumber?
                        result.first!.time              = myContact.timeStamp as NSNumber? // Int(Date().timeIntervalSince1970) as NSNumber?
                        if let contactLinkeUser = myContact.linkedUser {
                            let linkedUserObject = updateCMLinkedUserEntity(withLinkedUser: contactLinkeUser)
                            result.first!.linkedUser = linkedUserObject
                        }
                        contactToReturn = result.first!
                        saveContext(subject: "Update CMContact -update existing object-")
                        
                    } else {
                        let theContactEntity = NSEntityDescription.entity(forEntityName: "CMContact", in: context)
                        let theContact = CMContact(entity: theContactEntity!, insertInto: context)
                        theContact.blocked          = myContact.blocked as NSNumber?
                        theContact.cellphoneNumber  = myContact.cellphoneNumber
                        theContact.email            = myContact.email
                        theContact.firstName        = myContact.firstName
                        theContact.hasUser          = myContact.hasUser as NSNumber?
                        theContact.id               = myContact.id as NSNumber?
                        theContact.image            = myContact.image
                        theContact.lastName         = myContact.lastName
                        theContact.notSeenDuration  = myContact.notSeenDuration as NSNumber?
                        theContact.uniqueId         = myContact.uniqueId
                        theContact.userId           = myContact.userId as NSNumber?
                        theContact.time             = myContact.timeStamp as NSNumber? // Int(Date().timeIntervalSince1970) as NSNumber?
                        if let contactLinkeUser = myContact.linkedUser {
                            let linkedUserObject = updateCMLinkedUserEntity(withLinkedUser: contactLinkeUser)
                            theContact.linkedUser = linkedUserObject
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
    
    
    /*
     * Update CMLinkedUser Entity:
     *
     * -> fetch CMLinkedUser and see if we already had this linkedUser on the Cache or not
     * -> if we found one, we will update it's properties
     * -> if not, we will create an CMLinkedUser object and save it in the Cache
     *
     *  + Access:   Private
     *  + Inputs:
     *      - withLinkedUser:   LinkedUser
     *  + Outputs:
     *      - CMLinkedUser?
     *
     */
    func updateCMLinkedUserEntity(withLinkedUser myLinkedUser: LinkedUser) -> CMLinkedUser? {
        var linkedUserToReturn: CMLinkedUser?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMLinkedUser")
        if let linkedUserId = myLinkedUser.coreUserId {
            fetchRequest.predicate = NSPredicate(format: "coreUserId == %i", linkedUserId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMLinkedUser] {
                    if (result.count > 0) {
                        result.first!.coreUserId    = myLinkedUser.coreUserId as NSNumber?
                        result.first!.image         = myLinkedUser.image
                        result.first!.name          = myLinkedUser.name
                        result.first!.nickname      = myLinkedUser.nickname
                        result.first!.username      = myLinkedUser.username
                        linkedUserToReturn = result.first!
                        saveContext(subject: "Update CMLinkedUser -update existing object-")
                    } else {
                        let theLinkedUserEntity = NSEntityDescription.entity(forEntityName: "CMLinkedUser", in: context)
                        let theLinkedUser = CMLinkedUser(entity: theLinkedUserEntity!, insertInto: context)
                        
                        theLinkedUser.coreUserId    = myLinkedUser.coreUserId as NSNumber?
                        theLinkedUser.image         = myLinkedUser.image
                        theLinkedUser.name          = myLinkedUser.name
                        theLinkedUser.nickname      = myLinkedUser.nickname
                        theLinkedUser.username      = myLinkedUser.username
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
    
    
    /*
     * Update CMConversation Entity:
     *
     * -> fetch CMConversation objcets from the CMConversation Entity,
     *    and see if we already had this Conversation on the cache or not
     * -> if we found the object on the Entity, we will update the property values of it,
     * -> if not, we will create CMConversation object and save it on the Cache
     *
     *  + Access:   Private
     *  + Inputs:
     *      - withConversationObject:   Conversation
     *  + Outputs:
     *      - CMConversation?
     *
     */
    func updateCMConversationEntity(withConversationObject myThread: Conversation) -> CMConversation? {
        var conversationToReturn: CMConversation?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        if let threadId = myThread.id {
            fetchRequest.predicate = NSPredicate(format: "id == %i", threadId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                    if (result.count > 0) {
                        result.first!.admin                  = myThread.admin as NSNumber?
                        result.first!.canEditInfo            = myThread.canEditInfo as NSNumber?
                        result.first!.canSpam                = myThread.canSpam as NSNumber?
                        result.first!.descriptions           = myThread.description
                        result.first!.group                  = myThread.group as NSNumber?
                        result.first!.id                     = myThread.id as NSNumber?
                        result.first!.image                  = myThread.image
                        result.first!.joinDate               = myThread.joinDate as NSNumber?
                        result.first!.lastMessage            = myThread.lastMessage
                        result.first!.lastParticipantImage   = myThread.lastParticipantImage
                        result.first!.lastParticipantName    = myThread.lastParticipantName
                        result.first!.lastSeenMessageId      = myThread.lastSeenMessageId as NSNumber?
                        result.first!.metadata               = myThread.metadata
                        result.first!.mute                   = myThread.mute as NSNumber?
                        result.first!.participantCount       = myThread.participantCount as NSNumber?
                        result.first!.partner                = myThread.partner as NSNumber?
                        result.first!.partnerLastDeliveredMessageId  = myThread.partnerLastDeliveredMessageId as NSNumber?
                        result.first!.partnerLastSeenMessageId       = myThread.partnerLastSeenMessageId as NSNumber?
                        result.first!.title                  = myThread.title
                        result.first!.time                   = myThread.time as NSNumber?
                        result.first!.type                   = myThread.time as NSNumber?
                        result.first!.unreadCount            = myThread.unreadCount as NSNumber?
                        if let threadInviter = myThread.inviter {
                            let inviterObject = updateCMParticipantEntity(withParticipantsObject: threadInviter)
                            result.first!.inviter = inviterObject
                        }
                        if let threadLastMessageVO = myThread.lastMessageVO {
                            let messageObject = updateCMMessageEntity(withMessageObject: threadLastMessageVO)
                            result.first!.lastMessageVO = messageObject
                        }
                        if let threadParticipants = myThread.participants {
                            var threadParticipantsArr = [CMParticipant]()
                            for item in threadParticipants {
                                if let threadparticipant = updateCMParticipantEntity(withParticipantsObject: item) {
                                    threadParticipantsArr.append(threadparticipant)
                                    updateThreadParticipantEntity(inThreadId: Int(exactly: result.first!.id!)!, withParticipantId: Int(exactly: threadparticipant.id!)!)
                                }
                            }
                            result.first!.participants = threadParticipantsArr
                        }
                        conversationToReturn = result.first!
                        
                        saveContext(subject: "Update CMConversation -update existing object-")
                    } else {
                        let conversationEntity = NSEntityDescription.entity(forEntityName: "CMConversation", in: context)
                        let conversation = CMConversation(entity: conversationEntity!, insertInto: context)
                        conversation.admin                  = myThread.admin as NSNumber?
                        conversation.canEditInfo            = myThread.canEditInfo as NSNumber?
                        conversation.canSpam                = myThread.canSpam as NSNumber?
                        conversation.descriptions           = myThread.description
                        conversation.group                  = myThread.group as NSNumber?
                        conversation.id                     = myThread.id as NSNumber?
                        conversation.image                  = myThread.image
                        conversation.joinDate               = myThread.joinDate as NSNumber?
                        conversation.lastMessage            = myThread.lastMessage
                        conversation.lastParticipantImage   = myThread.lastParticipantImage
                        conversation.lastParticipantName    = myThread.lastParticipantName
                        conversation.lastSeenMessageId      = myThread.lastSeenMessageId as NSNumber?
                        conversation.metadata               = myThread.metadata
                        conversation.mute                   = myThread.mute as NSNumber?
                        conversation.participantCount       = myThread.participantCount as NSNumber?
                        conversation.partner                = myThread.partner as NSNumber?
                        conversation.partnerLastDeliveredMessageId  = myThread.partnerLastDeliveredMessageId as NSNumber?
                        conversation.partnerLastSeenMessageId       = myThread.partnerLastSeenMessageId as NSNumber?
                        conversation.title                  = myThread.title
                        conversation.time                   = myThread.time as NSNumber?
                        conversation.type                   = myThread.time as NSNumber?
                        conversation.unreadCount            = myThread.unreadCount as NSNumber?
                        if let threadInviter = myThread.inviter {
                            let inviterObject = updateCMParticipantEntity(withParticipantsObject: threadInviter)
                            conversation.inviter = inviterObject
                        }
                        if let threadLastMessageVO = myThread.lastMessageVO {
                            let messageObject = updateCMMessageEntity(withMessageObject: threadLastMessageVO)
                            conversation.lastMessageVO = messageObject
                        }
                        if let threadParticipants = myThread.participants {
                            var threadParticipantsArr = [CMParticipant]()
                            for item in threadParticipants {
                                if let threadparticipant = updateCMParticipantEntity(withParticipantsObject: item) {
                                    threadParticipantsArr.append(threadparticipant)
                                    updateThreadParticipantEntity(inThreadId: Int(exactly: conversation.id!)!, withParticipantId: Int(exactly: threadparticipant.id!)!)
                                }
                            }
                            conversation.participants = threadParticipantsArr
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
    
    
    /*
     * Update Participant Entity:
     *
     * -> fetch the CMParticipant objcet from the CMParticipant Entity,
     *    and see if we already had this Participant object on the cache or not
     * -> if we found the object on the Entity, we will update the property values of it
     * -> if not, we will create CMParticipant object and save it on the Cache
     *
     *  + Access:   Private
     *  + Inputs:
     *      - withConversationObject:   Conversation
     *  + Outputs:
     *      - CMConversation?
     *
     */
    func updateCMParticipantEntity(withParticipantsObject myParticipant: Participant) -> CMParticipant? {
        var participantObjectToReturn: CMParticipant?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        // if i found the CMParticipant onject, update its values
        if let participantId = myParticipant.id {
            fetchRequest.predicate = NSPredicate(format: "id == %i", participantId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                    if (result.count > 0) {
                        result.first!.admin             = myParticipant.admin as NSNumber?
                        result.first!.blocked           = myParticipant.blocked as NSNumber?
                        result.first!.cellphoneNumber   = myParticipant.cellphoneNumber
                        result.first!.contactId         = myParticipant.contactId as NSNumber?
                        result.first!.id                = myParticipant.id as NSNumber?
                        result.first!.email             = myParticipant.email
                        result.first!.firstName         = myParticipant.firstName
                        result.first!.id                = myParticipant.id as NSNumber?
                        result.first!.image             = myParticipant.image
                        result.first!.lastName          = myParticipant.lastName
                        result.first!.myFriend          = myParticipant.myFriend as NSNumber?
                        result.first!.name              = myParticipant.name
                        result.first!.notSeenDuration   = myParticipant.notSeenDuration as NSNumber?
                        result.first!.online            = myParticipant.online as NSNumber?
                        result.first!.receiveEnable     = myParticipant.receiveEnable as NSNumber?
                        result.first?.roles             = myParticipant.roles
                        result.first!.sendEnable        = myParticipant.sendEnable as NSNumber?
                        participantObjectToReturn = result.first!
                        
                        saveContext(subject: "Update CMParticipant -update existing object-")
                    } else {    // it means that we couldn't find the CMParticipant object on the cache, so we will create one
                        let theInviterEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
                        let theInviter = CMParticipant(entity: theInviterEntity!, insertInto: context)
                        theInviter.admin            = myParticipant.admin as NSNumber?
                        theInviter.blocked          = myParticipant.blocked as NSNumber?
                        theInviter.cellphoneNumber  = myParticipant.cellphoneNumber
                        theInviter.contactId        = myParticipant.contactId as NSNumber?
                        theInviter.id               = myParticipant.id as NSNumber?
                        theInviter.email            = myParticipant.email
                        theInviter.firstName        = myParticipant.firstName
                        theInviter.id               = myParticipant.id as NSNumber?
                        theInviter.image            = myParticipant.image
                        theInviter.lastName         = myParticipant.lastName
                        theInviter.myFriend         = myParticipant.myFriend as NSNumber?
                        theInviter.name             = myParticipant.name
                        theInviter.notSeenDuration  = myParticipant.notSeenDuration as NSNumber?
                        theInviter.online           = myParticipant.online as NSNumber?
                        theInviter.receiveEnable    = myParticipant.receiveEnable as NSNumber?
                        theInviter.roles            = myParticipant.roles
                        theInviter.sendEnable       = myParticipant.sendEnable as NSNumber?
                        participantObjectToReturn = theInviter
                        
                        saveContext(subject: "Update CMParticipant -create a new object-")
                    }
                }
            } catch {
                fatalError("Error on trying to find the participant from CMParticipant entity")
            }
        }
        return participantObjectToReturn
    }
    
    
    
    func updateThreadAdminEntity(inThreadId threadId: Int, roles: UserRole) -> ThreadAdmins? {
        /*
         *  -> fetch ThreadAdmins with threadId and userId
         *  -> if 'roles' Input, has some roles, then we will update or create threadAdmin
         *  -> otherwise we will delete that object from cache if that was exist
         *
         */
        var threadAdminObjectToReturn: ThreadAdmins?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ThreadAdmins")
        // if i found the ThreadAdmins onject, update its values
        fetchRequest.predicate = NSPredicate(format: "threadId == %i && userId == %i", threadId, roles.userId)
        do {
            if let result = try context.fetch(fetchRequest) as? [ThreadAdmins] {
                if (roles.roles?.count ?? 0 > 0) {
                    if (result.count > 0) {
                        result.first!.threadId  = threadId as NSNumber?
                        result.first?.name      = roles.name
                        result.first?.userId    = roles.userId as NSNumber?
                        var userRoles = [String]()
                        for role in roles.roles ?? [] {
                            userRoles.append(role)
                        }
                        result.first?.roles     = userRoles
                        threadAdminObjectToReturn = result.first
                        saveContext(subject: "Update ThreadAdmins -update existing object-")
                        
                    } else {    // it means that we couldn't find the ThreadAdmins object on the cache, so we will create one
                        let theThreadAdminEntity = NSEntityDescription.entity(forEntityName: "ThreadAdmins", in: context)
                        let threadAdmin = ThreadAdmins(entity: theThreadAdminEntity!, insertInto: context)
                        threadAdmin.threadId    = threadId as NSNumber?
                        threadAdmin.name        = roles.name
                        threadAdmin.userId      = roles.userId as NSNumber?
                        var userRoles = [String]()
                        for role in roles.roles ?? [] {
                            userRoles.append(role)
                        }
                        threadAdmin.roles       = userRoles
                        threadAdminObjectToReturn = threadAdmin
                        saveContext(subject: "Update ThreadAdmins -create a new object-")
                    }
                    
                } else {
                    if (result.count > 0) {
                        deleteAndSave(object: result.first!, withMessage: "Delete Admin from ThreadAdmin entity")
                        saveContext(subject: "Update ThreadAdmins -update existing object-")
                    }
                }
                
            }
        } catch {
            fatalError("Error on trying to find the object from ThreadAdmins entity")
        }
        return threadAdminObjectToReturn
    }
    
    
    
    
    /*
     * Update Message Entity:
     *
     * -> fetch the CMMessage objcet from the CMMessage Entity,
     *    and see if we already had this Participant object on the cache or not
     * -> if we found the object on the Entity, we will update the property values of it
     * -> if not, we will create CMMessage object and save it on the Cache
     *
     *  + Access:   Private
     *  + Inputs:
     *      - withMessageObject:    Message
     *  + Outputs:
     *      - CMMessage?
     *
     */
    func updateCMMessageEntity(withMessageObject myMessage: Message) -> CMMessage? {
        var messageObjectToReturn: CMMessage?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        if let messageId = myMessage.id {
            fetchRequest.predicate = NSPredicate(format: "id == %i", messageId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                    if (result.count > 0) {
                        result.first!.delivered    = myMessage.delivered as NSNumber?
                        result.first!.editable     = myMessage.editable as NSNumber?
                        result.first!.edited       = myMessage.edited as NSNumber?
                        result.first!.id           = myMessage.id as NSNumber?
                        result.first!.message      = myMessage.message
                        result.first!.messageType  = myMessage.messageType
                        result.first!.metaData     = myMessage.metaData
                        result.first!.ownerId      = myMessage.ownerId as NSNumber?
                        result.first!.previousId   = myMessage.previousId as NSNumber?
                        result.first!.seen         = myMessage.seen as NSNumber?
                        result.first!.threadId     = myMessage.threadId as NSNumber?
                        result.first!.time         = myMessage.time as NSNumber?
                        result.first!.uniqueId     = myMessage.uniqueId
                        if let messageConversation = myMessage.conversation {
                            if let conversationObject = updateCMConversationEntity(withConversationObject: messageConversation) {
                                result.first!.conversation = conversationObject
                            }
                        }
                        
                        if let messageForwardInfo = myMessage.forwardInfo {
                            let forward = updateCMForwardInfoEntity(withObject: messageForwardInfo)
                            result.first?.forwardInfo = forward
                        }
                        
                        if let messageParticipant = myMessage.participant {
                            if let participantObject = updateCMParticipantEntity(withParticipantsObject: messageParticipant) {
                                result.first!.participant = participantObject
                            }
                        }
                        
                        if let messageReplyInfo = myMessage.replyInfo {
                            if let reply = updateCMReplyInfoEntity(withObject: messageReplyInfo) {
                                result.first?.replyInfo = reply
                            }
                        }
                        
                        saveMessageGap(threadId:            result.first?.threadId as! Int,
                                       messageIds:          [result.first?.id as! Int],
                                       messagePreviousIds:  [result.first?.previousId as! Int])
                        messageObjectToReturn = result.first!
                        
                        saveContext(subject: "Update CMMessage -update existing object-")
                    } else {
                        let theMessageEntity = NSEntityDescription.entity(forEntityName: "CMMessage", in: context)
                        let theMessage = CMMessage(entity: theMessageEntity!, insertInto: context)
                        theMessage.delivered    = myMessage.delivered as NSNumber?
                        theMessage.editable     = myMessage.editable as NSNumber?
                        theMessage.edited       = myMessage.edited as NSNumber?
                        theMessage.id           = myMessage.id as NSNumber?
                        theMessage.message      = myMessage.message
                        theMessage.messageType  = myMessage.messageType
                        theMessage.metaData     = myMessage.metaData
                        theMessage.ownerId      = myMessage.ownerId as NSNumber?
                        theMessage.previousId   = myMessage.previousId as NSNumber?
                        theMessage.seen         = myMessage.seen as NSNumber?
                        theMessage.threadId     = myMessage.threadId as NSNumber?
                        theMessage.time         = myMessage.time as NSNumber?
                        theMessage.uniqueId     = myMessage.uniqueId
                        if let messageConversation = myMessage.conversation {
                            if let conversationObject = updateCMConversationEntity(withConversationObject: messageConversation) {
                                theMessage.conversation = conversationObject
                            }
                        }
                        
                        if let messageForwardInfo = myMessage.forwardInfo {
                            let forward = updateCMForwardInfoEntity(withObject: messageForwardInfo)
                            theMessage.forwardInfo = forward
                        }
                        
                        if let messageParticipant = myMessage.participant {
                            if let participantObject = updateCMParticipantEntity(withParticipantsObject: messageParticipant) {
                                theMessage.participant = participantObject
                            }
                        }
                        
                        if let messageReplyInfo = myMessage.replyInfo {
                            if let reply = updateCMReplyInfoEntity(withObject: messageReplyInfo) {
                                theMessage.replyInfo = reply
                            }
                        }
                        
                        saveMessageGap(threadId:            theMessage.threadId as! Int,
                                       messageIds:          [theMessage.id as! Int],
                                       messagePreviousIds:  [theMessage.previousId as! Int])
                        messageObjectToReturn = theMessage
                        
                        saveContext(subject: "Update CMMessage -create a new object-")
                    }
                }
            } catch {
                fatalError("")
            }
        }
        return messageObjectToReturn
    }
    
    
    
    func updateCMReplyInfoEntity(withObject myReplyInfo: ReplyInfo) -> CMReplyInfo? {
        var replyInfoObjectToReturn: CMReplyInfo?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMReplyInfo")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMReplyInfo] {
                if (result.count > 0) {
                    result.first?.deletedd          = myReplyInfo.deleted as NSNumber?
                    result.first?.message           = myReplyInfo.message
                    result.first?.messageType       = myReplyInfo.messageType as NSNumber?
                    result.first?.metadata          = myReplyInfo.metadata
                    result.first?.repliedToMessageId    = myReplyInfo.repliedToMessageId as NSNumber?
                    result.first?.systemMetadata    = myReplyInfo.systemMetadata
                    result.first?.time              = myReplyInfo.time as NSNumber?
                    if let participantObject = myReplyInfo.participant {
                        if let participantObject = updateCMParticipantEntity(withParticipantsObject: participantObject) {
                            result.first?.participant = participantObject
                        }
                    }
                    replyInfoObjectToReturn = result.first
                    saveContext(subject: "Update CMReplyInfo -update existing object-")
                } else {
                    let theCMReplyInfo = NSEntityDescription.entity(forEntityName: "CMReplyInfo", in: context)
                    let theReplyInfo = CMReplyInfo(entity: theCMReplyInfo!, insertInto: context)
                    theReplyInfo.deletedd           = myReplyInfo.deleted as NSNumber?
                    theReplyInfo.message            = myReplyInfo.message
                    theReplyInfo.messageType        = myReplyInfo.messageType as NSNumber?
                    theReplyInfo.metadata           = myReplyInfo.metadata
                    theReplyInfo.repliedToMessageId = myReplyInfo.repliedToMessageId as NSNumber?
                    theReplyInfo.systemMetadata     = myReplyInfo.systemMetadata
                    theReplyInfo.time               = myReplyInfo.time as NSNumber?
                    if let participantObject = myReplyInfo.participant {
                        if let participantObject = updateCMParticipantEntity(withParticipantsObject: participantObject) {
                            result.first?.participant = participantObject
                        }
                    }
                    replyInfoObjectToReturn = theReplyInfo
                    saveContext(subject: "Update CMReplyInfo -create a new object-")
                }
            }
        } catch {
            fatalError("")
        }
        return replyInfoObjectToReturn
    }
    
    func updateCMForwardInfoEntity(withObject myForwardInfo: ForwardInfo) -> CMForwardInfo? {
        var forwardInfoObjectToReturn: CMForwardInfo?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMForwardInfo")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMForwardInfo] {
                if (result.count > 0) {
                    if let theParticipantObject = myForwardInfo.participant {
                        if let participantObject = updateCMParticipantEntity(withParticipantsObject: theParticipantObject) {
                            result.first?.participant = participantObject
                        }
                    }
                    if let theConversationObject = myForwardInfo.conversation {
                        if let conversationObject = updateCMConversationEntity(withConversationObject: theConversationObject) {
                            result.first?.conversation = conversationObject
                        }
                    }
                    forwardInfoObjectToReturn = result.first
                    saveContext(subject: "Update CMForwardInfo -update existing object-")
                } else {
                    let theCMForwardInfo = NSEntityDescription.entity(forEntityName: "CMForwardInfo", in: context)
                    let theForwardInfo = CMForwardInfo(entity: theCMForwardInfo!, insertInto: context)
                    
                    if let theParticipantObject = myForwardInfo.participant {
                        if let participantObject = updateCMParticipantEntity(withParticipantsObject: theParticipantObject) {
                            theForwardInfo.participant = participantObject
                        }
                    }
                    if let theConversationObject = myForwardInfo.conversation {
                        if let conversationObject = updateCMConversationEntity(withConversationObject: theConversationObject) {
                            theForwardInfo.conversation = conversationObject
                        }
                    }
                    forwardInfoObjectToReturn = theForwardInfo
                    saveContext(subject: "Update CMForwardInfo -create a new object-")
                }
            }
        } catch {
            fatalError("")
        }
        return forwardInfoObjectToReturn
    }
    
    
    
    /*
     * Update ThreadParticipant Entity:
     *
     *
     *  + Access:   Private
     *  + Inputs:
     *      - threadId:         Int
     *      - participantId:    Int
     *  + Outputs:  _
     *
     */
    // update existing object or create new one
    func updateThreadParticipantEntity(inThreadId threadId: Int, withParticipantId participantId: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMThreadParticipants")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i AND participantId == %i", threadId, participantId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMThreadParticipants] {
                if (result.count > 0) {
                    result.first!.time = Int(Date().timeIntervalSince1970) as NSNumber?
                    saveContext(subject: "Update CMThreadParticipants -update existing object-")
                } else {
                    let theCMThreadParticipants = NSEntityDescription.entity(forEntityName: "CMThreadParticipants", in: context)
                    let theThreadParticipants = CMThreadParticipants(entity: theCMThreadParticipants!, insertInto: context)
                    theThreadParticipants.threadId      = threadId as NSNumber?
                    theThreadParticipants.participantId = participantId as NSNumber?
                    theThreadParticipants.time          = Int(Date().timeIntervalSince1970) as NSNumber?
                    saveContext(subject: "Update CMThreadParticipants -create new object-")
                }
            }
        } catch {
            fatalError("Error on trying to find CMThreadParticipants")
        }
        
    }
    
    func updateMessageGapEntity(inThreadId threadId: Int, withMessageId messageId: Int, withPreviousId previousId: Int) {
        /*
         * -> fetch MessageGaps where their threadId is equal to input 'threadId'
         *      -> check if we found any object on the MessageGaps, that is waiting for a messageId (its previousId property) that we have here on 'messageId'
         *          -> delete this object from MessageGaps Entity
         *      -> check if we found the message on the MessageGaps, we will update its values
         *      -> otherwise we will create a MessageGaps object and assing input values to this object
         *
         */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MessageGaps")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [MessageGaps] {
                for item in result {
                    // means that we found previousId of this message, so we have to delete this message from gap
                    if ((item.previousId as? Int) == messageId) {
                        deleteAndSave(object: item, withMessage: "Update MessageGaps -delete object-")
                    }
                    if ((item.messageId as? Int) == messageId) {
                        item.previousId = previousId as NSNumber?
                        item.messageId  = messageId as NSNumber?
                        item.threadId   = threadId as NSNumber?
                        saveContext(subject: "Update MessageGaps -update existing object-")
                    } else {
                        let theMessageGapsEntity = NSEntityDescription.entity(forEntityName: "MessageGaps", in: context)
                        let theMessageGap = MessageGaps(entity: theMessageGapsEntity!, insertInto: context)
                        theMessageGap.threadId      = threadId  as NSNumber?
                        theMessageGap.messageId     = messageId as NSNumber?
                        theMessageGap.previousId    = previousId as NSNumber?
                        saveContext(subject: "Update MessageGaps -create new object-")
                    }
                }
            }
        } catch {
            fatalError("Error on trying to find MessageGaps")
        }
        
    }
    
    
}

