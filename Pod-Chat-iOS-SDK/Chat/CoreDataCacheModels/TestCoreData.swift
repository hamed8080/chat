//
//  TestCoreData.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import CoreData

import SwiftyBeaver
import SwiftyJSON


enum fileSubPath: String {
    case Files = "/Chat/Files/"
    case Images = "/Chat/Images/"
}

enum Ordering: String {
    case ascending  = "asc"
    case descending = "desc"
}


public class Cache {
    
    var coreDataStack: CoreDataStack = CoreDataStack()
    public let context: NSManagedObjectContext
    
    public init() {
        
        context = coreDataStack.persistentContainer.viewContext
        print("context created")
    }
    
    func saveContext(subject: String) {
        do {
            try context.save()
            print("\(subject); has Saved Successfully on CoreData Cache")
        } catch {
            fatalError("\(subject); Error to save data on CoreData Cache")
        }
    }
    
    
    func deleteAndSave(object: NSManagedObject, withMessage message: String) {
        context.delete(object)
        saveContext(subject: message)
    }
    
    
}






extension Cache {
    
    /*
     This function will fetch the CMConversation objcet from the CMConversation Entity,
     and if it, finds the object on the Entity, it will update the property values of it,
     if not, it will create one.
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
     This function will fetch the CMParticipant objcet from the CMParticipant Entity,
     and if it, finds the object on the Entity, it will update the property values of it,
     if not, it will create one.
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
                        result.first!.admin           = myParticipant.admin as NSNumber?
                        result.first!.blocked         = myParticipant.blocked as NSNumber?
                        result.first!.cellphoneNumber = myParticipant.cellphoneNumber
                        result.first!.contactId       = myParticipant.contactId as NSNumber?
                        result.first!.id              = myParticipant.id as NSNumber?
                        result.first!.email           = myParticipant.email
                        result.first!.firstName       = myParticipant.firstName
                        result.first!.id              = myParticipant.id as NSNumber?
                        result.first!.image           = myParticipant.image
                        result.first!.lastName        = myParticipant.lastName
                        result.first!.myFriend        = myParticipant.myFriend as NSNumber?
                        result.first!.name            = myParticipant.name
                        result.first!.notSeenDuration = myParticipant.notSeenDuration as NSNumber?
                        result.first!.online          = myParticipant.online as NSNumber?
                        result.first!.receiveEnable   = myParticipant.receiveEnable as NSNumber?
                        result.first!.sendEnable      = myParticipant.sendEnable as NSNumber?
                        participantObjectToReturn = result.first!
                        
                        saveContext(subject: "Update CMParticipant -update existing object-")
                    } else {    // it means that we couldn't find the CMParticipant object on the cache, so we will create one
                        let theInviterEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
                        let theInviter = CMParticipant(entity: theInviterEntity!, insertInto: context)
                        theInviter.admin           = myParticipant.admin as NSNumber?
                        theInviter.blocked         = myParticipant.blocked as NSNumber?
                        theInviter.cellphoneNumber = myParticipant.cellphoneNumber
                        theInviter.contactId       = myParticipant.contactId as NSNumber?
                        theInviter.id              = myParticipant.id as NSNumber?
                        theInviter.email           = myParticipant.email
                        theInviter.firstName       = myParticipant.firstName
                        theInviter.id              = myParticipant.id as NSNumber?
                        theInviter.image           = myParticipant.image
                        theInviter.lastName        = myParticipant.lastName
                        theInviter.myFriend        = myParticipant.myFriend as NSNumber?
                        theInviter.name            = myParticipant.name
                        theInviter.notSeenDuration = myParticipant.notSeenDuration as NSNumber?
                        theInviter.online          = myParticipant.online as NSNumber?
                        theInviter.receiveEnable   = myParticipant.receiveEnable as NSNumber?
                        theInviter.sendEnable      = myParticipant.sendEnable as NSNumber?
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
    
    
    
    //    func updateCMThreadParticipantEntity(withParticipantsObject myParticipant: [Participant], inThreadId threadId: Int) -> CMParticipant {
    //        var participantToReturn: CMParticipant?
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
    //        fetchRequest.predicate = NSPredicate(format: "id == %i", threadId)
    //        do {
    //            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
    //                if (result.count > 0) {
    //                        var threadParticipantsArr = [CMParticipant]()
    //                        for item in myParticipant {
    //                            if let threadparticipant = updateCMParticipantEntity(withParticipantsObject: item) {
    //                                threadParticipantsArr.append(threadparticipant)
    //                                updateThreadParticipantEntity(inThreadId: Int(exactly: result.first!.id!)!, withParticipantId: Int(exactly: threadparticipant.id!)!)
    //                            }
    //                        }
    //                        result.first!.participants = threadParticipantsArr
    //
    //                    participantToReturn = result.first!
    //
    //                    saveContext(subject: "Update CMConversation -update existing object-")
    //                }
    //            }
    //        } catch {
    //            fatalError("Error on trying to find the thread from CMConversation entity")
    //        }
    //    }
    
    
    /*
     This function will fetch the CMMessage objcet from the CMMessage Entity,
     and if it, finds the object on the Entity, it will update the property values of it,
     if not, it will create one.
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
                        
                        // TODO: handle ForwardInfo
                        /*
                         if let messageForwardInfo = myMessage.forwardInfo {
                         
                         }
                         */
                        
                        if let messageParticipant = myMessage.participant {
                            if let participantObject = updateCMParticipantEntity(withParticipantsObject: messageParticipant) {
                                result.first!.participant = participantObject
                            }
                        }
                        
                        // TODO: handle ReplyInfo
                        /*
                         if let messageReplyInfo = myMessage.replyInfo {
                         
                         }
                         */
                        
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
                        
                        // TODO: handle ForwardInfo
                        /*
                         if let messageForwardInfo = myMessage.forwardInfo {
                         
                         }
                         */
                        
                        if let messageParticipant = myMessage.participant {
                            if let participantObject = updateCMParticipantEntity(withParticipantsObject: messageParticipant) {
                                theMessage.participant = participantObject
                            }
                        }
                        
                        // TODO: handle ReplyInfo
                        /*
                         if let messageReplyInfo = myMessage.replyInfo {
                         
                         }
                         */
                        
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
    
    
    // TODO:
    //    func updateCMReplyInfoEntity(withObject myReplyInfo: ReplyInfo) -> CMReplyInfo? {
    //        var replyInfoObjectToReturn: ReplyInfo?
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMReplyInfo")
    //
    //    }
    //    func updateCMReplyInfoEntity(withObject myReplyInfo: ForwardInfo) -> CMForwardInfo? {
    //        var forwardInfoObjectToReturn: ForwardInfo?
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMForwardInfo")
    //
    //    }
    
    
    func updateCMContactEntity(withMessageObject myContact: Contact) -> CMContact? {
        var contactToReturn: CMContact?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        if let contactId = myContact.id {
            fetchRequest.predicate = NSPredicate(format: "id == %i", contactId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMContact] {
                    if (result.count > 0) {
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
    
    
    func updateCMLinkedUserEntity(withLinkedUser myLinkedUser: LinkedUser) -> CMLinkedUser? {
        var linkedUserToReturn: CMLinkedUser?
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMLinkedUser")
        if let linkedUserId = myLinkedUser.id {
            fetchRequest.predicate = NSPredicate(format: "id == %i", linkedUserId)
            do {
                if let result = try context.fetch(fetchRequest) as? [CMLinkedUser] {
                    if (result.count > 0) {
                        result.first!.id            = myLinkedUser.id as NSNumber?
                        result.first!.image         = myLinkedUser.image
                        result.first!.name          = myLinkedUser.name
                        result.first!.nickname      = myLinkedUser.nickname
                        result.first!.username      = myLinkedUser.username
                        
                        linkedUserToReturn = result.first!
                        
                        saveContext(subject: "Update CMLinkedUser -update existing object-")
                    } else {
                        let theLinkedUserEntity = NSEntityDescription.entity(forEntityName: "CMLinkedUser", in: context)
                        let theLinkedUser = CMLinkedUser(entity: theLinkedUserEntity!, insertInto: context)
                        
                        theLinkedUser.id            = myLinkedUser.id as NSNumber?
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
    
    
    
}




// MARK: - Functions that will save data on CoreData Cache

extension Cache {
    
    // this function will save (or update) the UserInfo in the Cache.
    public func createUserInfoObject(user: User) {
        // check if there is any information about UserInfo in the cache
        // if it has some data, it we will update that data,
        // otherwise we will create an object and save data on cache
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUser")
        do {
            
            if let result = try context.fetch(fetchRequest) as? [CMUser] {
                // if there is a value in this fetch request, it mean that we had already saved UserInfo in the Cache.
                // so we just have to update that information with new response that comes from server
                if (result.count > 0) {
                    result.first!.cellphoneNumber   = user.cellphoneNumber
                    result.first!.email             = user.email
                    result.first!.id                = NSNumber(value: user.id ?? 0)
                    result.first!.image             = user.image
                    result.first!.lastSeen          = NSNumber(value: user.lastSeen ?? 0)
                    result.first!.name              = user.name
                    result.first!.receiveEnable     = NSNumber(value: user.receiveEnable ?? true)
                    result.first!.sendEnable        = NSNumber(value: user.sendEnable ?? true)
                    
                    // save function that will try to save changes that made on the Cache
                    saveContext(subject: "Update UserInfo -update existing object-")
                    
                } else {
                    // if there wasn't any CMUser object (means there is no information about UserInfo on the Cache)
                    // this part will execute, which will create an object of User and save it on the Cache
                    let theUserEntity = NSEntityDescription.entity(forEntityName: "CMUser", in: context)
                    let theUser = CMUser(entity: theUserEntity!, insertInto: context)
                    
                    theUser.cellphoneNumber    = user.cellphoneNumber
                    theUser.email              = user.email
                    theUser.id                 = user.id as NSNumber?
                    theUser.image              = user.image
                    theUser.lastSeen           = user.lastSeen as NSNumber?
                    theUser.name               = user.name
                    theUser.receiveEnable      = user.receiveEnable as NSNumber?
                    theUser.sendEnable         = user.sendEnable as NSNumber?
                    
                    // save function that will try to save changes that made on the Cache
                    saveContext(subject: "Update UserInfo -create a new object-")
                }
            }
        } catch {
            fatalError("Error on fetching list of Conversations")
        }
    }
    
    
    
    // this function will save (or update) threads that comes from server, into the Cache.
    public func saveThreadObjects(threads: [Conversation]) {
        
        for item in threads {
            _ = updateCMConversationEntity(withConversationObject: item)
        }
        
        /*
         // check if there is any information about Conversations that are in the cache,
         // which if it has been there, it we will update that data,
         // otherwise we will create an object and save data on cache
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
         do {
         if let result = try context.fetch(fetchRequest) as? [CMConversation] {
         
         // Part1:
         // find data that are exist in the Cache, (and the response request is containing that). and delete them
         for item in threads {
         for itemInCache in result {
         if let conversationId = Int(exactly: itemInCache.id ?? 0) {
         print("Conversation id = \(item.id ?? 99999) ; CMConversation id = \(conversationId)")
         if (conversationId == item.id) {
         // the conversation object that we are going to create, is already exist in the Cache
         // to update information in this object:
         // we will delete them first, then we will create it again later
         
         if let _ = itemInCache.inviter {
         context.delete(itemInCache.inviter!)
         saveContext(subject: "Delete CMParticipant Object as inviter")
         }
         if let _ = itemInCache.lastMessageVO {
         context.delete(itemInCache.lastMessageVO!)
         saveContext(subject: "Delete CMMessage Object as lastMessageVO")
         }
         if let _ = itemInCache.participants {
         for item in itemInCache.participants! {
         context.delete(item)
         saveContext(subject: "Delete CMParticipant Object as object in participants")
         }
         }
         
         //                                itemInCache.inviter = nil
         //                                itemInCache.lastMessageVO = nil
         //                                itemInCache.participants = nil
         context.delete(itemInCache)
         
         saveContext(subject: "Delete CMConversation Object")
         }
         }
         }
         }
         
         // Part2:
         // save data comes from server to the Cache
         var allThreads = [CMConversation]()
         
         for item in threads {
         let conversationEntity = NSEntityDescription.entity(forEntityName: "CMConversation", in: context)
         let conversation = CMConversation(entity: conversationEntity!, insertInto: context)
         
         conversation.admin                  = item.admin as NSNumber?
         conversation.canEditInfo            = item.canEditInfo as NSNumber?
         conversation.canSpam                = item.canSpam as NSNumber?
         conversation.descriptions           = item.description
         conversation.group                  = item.group as NSNumber?
         conversation.id                     = item.id as NSNumber?
         conversation.image                  = item.image
         conversation.joinDate               = item.joinDate as NSNumber?
         conversation.lastMessage            = item.lastMessage
         conversation.lastParticipantImage   = item.lastParticipantImage
         conversation.lastParticipantName    = item.lastParticipantName
         conversation.lastSeenMessageId      = item.lastSeenMessageId as NSNumber?
         conversation.metadata               = item.metadata
         conversation.mute                   = item.mute as NSNumber?
         conversation.participantCount       = item.participantCount as NSNumber?
         conversation.partner                = item.partner as NSNumber?
         conversation.partnerLastDeliveredMessageId  = item.partnerLastDeliveredMessageId as NSNumber?
         conversation.partnerLastSeenMessageId       = item.partnerLastSeenMessageId as NSNumber?
         conversation.title                  = item.title
         conversation.time                   = item.time as NSNumber?
         conversation.type                   = item.time as NSNumber?
         conversation.unreadCount            = item.unreadCount as NSNumber?
         
         
         let theInviterEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theInviter = CMParticipant(entity: theInviterEntity!, insertInto: context)
         theInviter.admin           = item.inviter?.admin as NSNumber?
         theInviter.blocked         = item.inviter?.blocked as NSNumber?
         theInviter.cellphoneNumber = item.inviter?.cellphoneNumber
         theInviter.contactId       = item.inviter?.contactId as NSNumber?
         theInviter.coreUserId      = item.inviter?.coreUserId as NSNumber?
         theInviter.email           = item.inviter?.email
         theInviter.firstName       = item.inviter?.firstName
         theInviter.id              = item.inviter?.id as NSNumber?
         theInviter.image           = item.inviter?.image
         theInviter.lastName        = item.inviter?.lastName
         theInviter.myFriend        = item.inviter?.myFriend as NSNumber?
         theInviter.name            = item.inviter?.name
         theInviter.notSeenDuration = item.inviter?.notSeenDuration as NSNumber?
         theInviter.online          = item.inviter?.online as NSNumber?
         theInviter.receiveEnable   = item.inviter?.receiveEnable as NSNumber?
         theInviter.sendEnable      = item.inviter?.sendEnable as NSNumber?
         conversation.inviter = theInviter
         
         
         let theMessageEntity = NSEntityDescription.entity(forEntityName: "CMMessage", in: context)
         let theMessage = CMMessage(entity: theMessageEntity!, insertInto: context)
         theMessage.delivered    = item.lastMessageVO?.delivered as NSNumber?
         theMessage.editable     = item.lastMessageVO?.editable as NSNumber?
         theMessage.edited       = item.lastMessageVO?.edited as NSNumber?
         theMessage.id           = item.lastMessageVO?.id as NSNumber?
         theMessage.message      = item.lastMessageVO?.message
         theMessage.messageType  = item.lastMessageVO?.messageType
         theMessage.metaData     = item.lastMessageVO?.metaData
         theMessage.ownerId      = item.lastMessageVO?.ownerId as NSNumber?
         theMessage.previousId   = item.lastMessageVO?.previousId as NSNumber?
         theMessage.seen         = item.lastMessageVO?.seen as NSNumber?
         theMessage.threadId     = item.lastMessageVO?.threadId as NSNumber?
         theMessage.time         = item.lastMessageVO?.time as NSNumber?
         theMessage.uniqueId     = item.lastMessageVO?.uniqueId
         //                    theMessage.conversation = item.lastMessageVO?.conversation
         //                    theMessage.forwardInfo  = item.lastMessageVO?.forwardInfo
         //                    theMessage.participant  = item.lastMessageVO?.participant
         //                    theMessage.replyInfo    = item.lastMessageVO?.replyInfo
         conversation.lastMessageVO = theMessage
         
         if let messagParticipants = item.participants {
         var participantArr = [CMParticipant]()
         for part in messagParticipants {
         let theParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theParticipant = CMParticipant(entity: theParticipantEntity!, insertInto: context)
         theParticipant.admin           = part.admin as NSNumber?
         theParticipant.blocked         = part.blocked as NSNumber?
         theParticipant.cellphoneNumber = part.cellphoneNumber
         theParticipant.contactId       = part.contactId as NSNumber?
         theParticipant.coreUserId      = part.coreUserId as NSNumber?
         theParticipant.email           = part.email
         theParticipant.firstName       = part.firstName
         theParticipant.id              = part.id as NSNumber?
         theParticipant.image           = part.image
         theParticipant.lastName        = part.lastName
         theParticipant.myFriend        = part.myFriend as NSNumber?
         theParticipant.name            = part.name
         theParticipant.notSeenDuration = part.notSeenDuration as NSNumber?
         theParticipant.online          = part.online as NSNumber?
         theParticipant.receiveEnable   = part.receiveEnable as NSNumber?
         theParticipant.sendEnable      = part.sendEnable as NSNumber?
         participantArr.append(theParticipant)
         }
         conversation.participants = participantArr
         }
         
         allThreads.append(conversation)
         }
         
         saveContext(subject: "Update CMConversation")
         }
         } catch {
         fatalError("Error on fetching list of CMConversation")
         }
         */
        
    }
    
    
    // this function will save (or update) contacts that comes from server, into the Cache.
    public func saveContactObjects(contacts: [Contact]) {
        
        for item in contacts {
            _ = updateCMContactEntity(withMessageObject: item)
        }
        
        /*
         // check if there is any information about Contact that are in the cache,
         // if they has beed there, it we will update that data,
         // otherwise we will create an object and save data on cache
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
         do {
         if let result = try context.fetch(fetchRequest) as? [CMContact] {
         
         // Part1:
         // find data that are exist in the Cache, (and the response request is containing that). and delete them
         for item in contacts {
         for itemInCache in result {
         if let contactId = Int(exactly: itemInCache.id ?? 0) {
         if (contactId == item.id) {
         // the contact object that we are going to create, is already exist in the Cache
         // to update information in this object:
         // we will delete them first, then we will create it again later
         
         itemInCache.linkedUser = nil
         context.delete(itemInCache)
         
         saveContext(subject: "Delete CMContact Object")
         }
         }
         
         }
         }
         
         // Part2:
         // save data comes from server to the Cache
         var allContacts = [CMContact]()
         
         for item in contacts {
         let theContactEntity = NSEntityDescription.entity(forEntityName: "CMContact", in: context)
         let theContact = CMContact(entity: theContactEntity!, insertInto: context)
         
         theContact.cellphoneNumber  = item.cellphoneNumber
         theContact.email            = item.email
         theContact.firstName        = item.firstName
         theContact.hasUser          = item.hasUser as NSNumber?
         theContact.id               = item.id as NSNumber?
         theContact.image            = item.image
         theContact.lastName         = item.lastName
         theContact.notSeenDuration  = item.notSeenDuration as NSNumber?
         theContact.uniqueId         = item.uniqueId
         theContact.userId           = item.userId as NSNumber?
         
         let theLinkedUserEntity = NSEntityDescription.entity(forEntityName: "CMLinkedUser", in: context)
         let theLinkedUser = CMLinkedUser(entity: theLinkedUserEntity!, insertInto: context)
         theLinkedUser.coreUserId    = item.linkedUser?.coreUserId as NSNumber?
         theLinkedUser.image         = item.linkedUser?.image
         theLinkedUser.name          = item.linkedUser?.name
         theLinkedUser.nickname      = item.linkedUser?.nickname
         theLinkedUser.username      = item.linkedUser?.username
         
         theContact.linkedUser = theLinkedUser
         
         allContacts.append(theContact)
         }
         
         saveContext(subject: "Update CMContact")
         }
         } catch {
         fatalError("Error on fetching list of CMConversation")
         }
         */
        
    }
    
    
    public func savePhoneBookContact(contact myContact: AddContactsRequestModel) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhoneContact")
        if let contactCellphoneNumber = myContact.cellphoneNumber {
            fetchRequest.predicate = NSPredicate(format: "cellphoneNumber == %@", contactCellphoneNumber)
            do {
                if let result = try context.fetch(fetchRequest) as? [PhoneContact] {
                    if (result.count > 0) {
                        result.first!.cellphoneNumber   = myContact.cellphoneNumber
                        result.first!.email             = myContact.email
                        result.first!.firstName         = myContact.firstName
                        result.first!.lastName          = myContact.lastName
                        
                        saveContext(subject: "Update PhoneContact -update existing object-")
                    }
                } else {
                    let theContactEntity = NSEntityDescription.entity(forEntityName: "PhoneContact", in: context)
                    let theContact = CMContact(entity: theContactEntity!, insertInto: context)
                    
                    theContact.cellphoneNumber  = myContact.cellphoneNumber
                    theContact.email            = myContact.email
                    theContact.firstName        = myContact.firstName
                    theContact.lastName         = myContact.lastName
                    
                    saveContext(subject: "Update PhoneContact -create new object-")
                }
            } catch {
                fatalError("Error on trying to find the contact from PhoneContact entity")
            }
        }
        
    }
    
    // this function will save (or update) contacts that comes from server, in the Cache.
    public func saveThreadParticipantObjects(whereThreadIdIs threadId: Int, withParticipants participants: [Participant]) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        fetchRequest.predicate = NSPredicate(format: "id == %i", threadId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                if (result.count > 0) {
                    for item in participants {
                        if let myCMParticipantObject = updateCMParticipantEntity(withParticipantsObject: item) {
                            
                            result.first!.addToParticipants(myCMParticipantObject)
                            //                                result.first!.participants!.append(myCMParticipantObject)
                            saveContext(subject: "Add/Update CMParticipant in a thread and Update CMConversation")
                            updateThreadParticipantEntity(inThreadId: Int(exactly: result.first!.id!)!, withParticipantId: Int(exactly: item.id!)!)
                        }
                    }
                }
                saveContext(subject: "Update CMConversation after adding/updating new Participant")
            }
        } catch {
            fatalError("Error on getting CMConversation when trying to add/update thread participants")
        }
        
        
        //        for item in participants {
        //            _ = updateCMParticipantEntity(withParticipantsObject: item)
        //        }
        
        /*
         // check if there is any information about Contact that are in the cache,
         // if they has beed there, it we will update that data,
         // otherwise we will create an object and save data on cache
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
         do {
         if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
         
         // Part1:
         // find data that are exist in the Cache, (and the response request is containing that). and delete them
         for item in participants {
         for itemInCache in result {
         if let participantId = Int(exactly: itemInCache.id ?? 0) {
         if (participantId == item.id) {
         // the Participant object that we are going to create, is already exist in the Cache
         // to update information in this object:
         // we will delete them first, then we will create it again later
         
         context.delete(itemInCache)
         
         saveContext(subject: "Delete CMParticipant Object")
         }
         }
         
         }
         }
         
         
         // Part2:
         // save data comes from server to the Cache
         var allParticipants = [CMParticipant]()
         
         for item in participants {
         let theParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theParticipant = CMParticipant(entity: theParticipantEntity!, insertInto: context)
         
         theParticipant.admin           = item.admin as NSNumber?
         theParticipant.blocked         = item.blocked as NSNumber?
         theParticipant.cellphoneNumber = item.cellphoneNumber
         theParticipant.contactId       = item.contactId as NSNumber?
         theParticipant.coreUserId      = item.coreUserId as NSNumber?
         theParticipant.email           = item.email
         theParticipant.firstName       = item.firstName
         theParticipant.id              = item.id as NSNumber?
         theParticipant.image           = item.image
         theParticipant.lastName        = item.lastName
         theParticipant.myFriend        = item.myFriend as NSNumber?
         theParticipant.name            = item.name
         theParticipant.notSeenDuration = item.notSeenDuration as NSNumber?
         theParticipant.online          = item.online as NSNumber?
         theParticipant.receiveEnable   = item.receiveEnable as NSNumber?
         theParticipant.sendEnable      = item.sendEnable as NSNumber?
         
         allParticipants.append(theParticipant)
         }
         
         saveContext(subject: "Update ThreadParticipants")
         
         }
         } catch {
         fatalError("Error on fetching list of CMConversation")
         }
         */
        
    }
    
    
    // this function will save (or update) messages that comes from server, in the Cache.
    public func saveMessageObjects(messages: [Message], getHistoryParams: JSON?) {
        
        if let params       = getHistoryParams {
            let count       = params["count"].intValue
            let offset      = params["offset"].intValue
            let id          = params["id"].int
            let fromTime    = params["fromTime"].uInt
            let toTime      = params["toTime"].uInt
            let order       = params["order"].string
            let query       = params["query"].string
            let threadId    = params["threadId"].int
            //            let uniqueId    = params["uniqueId"].string
            
            switch (count, offset, id, fromTime, toTime, order, query, messages.count) {
                
            // 1- delete everything from cache
            case (count, 0, .none, .none, .none, _, .none, 0):
                deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: offset, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                
            // 2- delete all records that:     'time' > 'time' (first cache result)
            case (count, offset, .none, .none, .none, Ordering.ascending.rawValue, .none, 0):
                var firstObject: Message?
                let fetchRequest = retrieveMessageHistoryFetchRequest(firstMessageId: nil, fromTime: nil, messageId: nil, lastMessageId: nil, order: nil, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                do {
                    if let result = try context.fetch(fetchRequest) as? [Message] {
                        if result.count > 0 {
                            firstObject = result.first!
                        }
                    }
                } catch {
                    fatalError()
                }
                if let fObject = firstObject {
                    if let firstObjectTime = fObject.time {
                        deleteMessage(count: nil, fromTime: firstObjectTime, messageId: nil, offset: offset, order: Ordering.ascending.rawValue, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                    }
                }
                
                
            // 3- delete all records that:     'time' < 'time' (first cache result)
            case (count, offset, .none, .none, .none, Ordering.descending.rawValue, .none, 0):
                var lastObject: Message?
                let fetchRequest = retrieveMessageHistoryFetchRequest(firstMessageId: nil, fromTime: nil, messageId: nil, lastMessageId: nil, order: nil, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                do {
                    if let result = try context.fetch(fetchRequest) as? [Message] {
                        if result.count > 0 {
                            lastObject = result.last!
                        }
                    }
                } catch {
                    fatalError()
                }
                if let lObject = lastObject {
                    if let lastObjectTime = lObject.time {
                        deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: offset, order: Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: lastObjectTime, uniqueId: nil)
                    }
                }
                
                
                //Server result is not Empty, so we should remove everything which are between firstMessage and lastMessage of this result from cache database and insert the new result into cache, so the deleted ones would be deleted
                
                
                // Offset has been set as 0 so this result is either the very beggining part of thread or the very last Depending on the sort order.
                // 6: Results are sorted ASC, and the offet is 0, so the first Messasge of this result is first Message of thread, everything in cache database which has smaller time than this one should be removed
                //  delete all records that::   'time' < result.first.time
            // delete every message between result.first and result.last from cache + then add new messages to the database
            case (count, 0, .none, .none, .none, Ordering.ascending.rawValue, .none, _):
                deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: 0, order: Ordering.ascending.rawValue, query: nil, threadId: threadId, toTime: messages.first!.time!, uniqueId: nil)
                deleteMessage(count: nil, fromTime: messages.first!.time!, messageId: nil, offset: 0, order: Ordering.ascending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                
                // 7: Results are sorted DESC and the offset is 0, so the last Message of this result is the last Message of the thread, everything in cache database which has bigger time than this one should be removed from cache
                //  delete all records that::   'time' > result.last.time
            // delete every message between result.first and result.last from cache + then add new messages to the database
            case (count, 0, .none, .none, .none, Ordering.descending.rawValue, .none, _):
                deleteMessage(count: nil, fromTime: messages.last!.time!, messageId: nil, offset: 0, order: Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                deleteMessage(count: nil, fromTime: messages.first!.time!, messageId: nil, offset: 0, order: Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                
                
                // 4- (result.last.previousId = nil) => delete all recored befor the result.last
            // delete every message between result.first and result.last from cache + then add new messages to the database
            case (count, offset, .none, .none, .none, Ordering.ascending.rawValue, .none, _):
                if (messages.last!.previousId == nil) {
                    deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: 0, order: Ordering.ascending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                }
                deleteMessage(count: nil, fromTime: messages.first!.time!, messageId: nil, offset: 0, order: Ordering.ascending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                
                // 5- if (result.first.previousId = nil) => delete all recored befor the result.first
            // delete every message between result.first and result.last from cache + then add new messages to the database
            case (count, offset, .none, .none, .none, Ordering.descending.rawValue, .none, _):
                if (messages.last!.previousId == nil) {
                    deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: 0, order: Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                }
                deleteMessage(count: nil, fromTime: messages.first!.time!, messageId: nil, offset: 0, order: Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: messages.last!.time!, uniqueId: nil)
                
                
            // whereClasue is not empty and we should check for every single one of the conditions to update the cache properly
            case let (count, offset, id, from, to, order, query, result):
                // When user ordered a message with exact ID and server returns [] but there is something in cache database, we should delete that row from cache, because it has been deleted
                if let myId = id {
                    if result == 0 {
                        // delete the message with 'id' from cache
                        deleteMessage(count: nil, fromTime: nil, messageId: myId, offset: 0, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                    }
                }
                
                // When user sets a query to search on messages we should delete all the results came from cache and insert new results instead, because those messages would be either removed or updated
                if let myQuery = query {
                    // delete result of the cache + then add new result to the cache
                    deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: 0, order: order ?? Ordering.descending.rawValue, query: myQuery, threadId: threadId, toTime: nil, uniqueId: nil)
                }
                
                /*
                 User set both fromTime and toTime, so we have a boundry restriction in this case.
                 if server result is empty, we should delete all messages from cache which are between fromTime and toTime.
                 if there are any messages on server in this boundry, we should delete all messages which are between time of first and last message of the server result, from cache and insert new result into cache.
                 */
                if (from != nil) || (to != nil) {
                    
                    // Server response is Empty []
                    if result == 0 {
                        
                        if (from != nil) && (to != nil) {
                            deleteMessage(count: nil, fromTime: from, messageId: nil, offset: 0, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: to, uniqueId: nil)
                            
                        } else if let fromTime = from {
                            deleteMessage(count: nil, fromTime: fromTime, messageId: nil, offset: 0, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: nil, uniqueId: nil)
                            
                        } else if let toTime = to {
                            deleteMessage(count: nil, fromTime: nil, messageId: nil, offset: 0, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: toTime, uniqueId: nil)
                        }
                        
                    }
                        
                        // Server response is not Empty [..., n-1, n, n+1, ...]
                    else {
                        deleteMessage(count: count, fromTime: from, messageId: nil, offset: offset, order: order ?? Ordering.descending.rawValue, query: nil, threadId: threadId, toTime: to, uniqueId: nil)
                    }
                    
                }
                
                
            }
            
            
            
        }
        
        // now insert server result in the cache
        for item in messages {
            _ = updateCMMessageEntity(withMessageObject: item)
        }
        
        
        
        /*
         // check if there is any information about Messages that are in the cache,
         // which if it has been there, it we will update that data,
         // otherwise we will create an object and save data on cache
         let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
         do {
         if let result = try context.fetch(fetchRequest) as? [CMMessage] {
         
         // Part1:
         // find data that are exist in the Cache, (and the response request is containing that). and delete them
         for item in messages {
         for itemInCache in result {
         if let messageId = Int(exactly: itemInCache.id ?? 0) {
         if (messageId == item.id) {
         // the message object that we are going to create, is already exist in the Cache
         // to update information in this object:
         // we will delete them first, then we will create it again later
         
         itemInCache.conversation = nil
         itemInCache.forwardInfo?.conversation = nil
         itemInCache.forwardInfo?.participant = nil
         itemInCache.forwardInfo = nil
         itemInCache.participant = nil
         itemInCache.replyInfo?.participant = nil
         itemInCache.replyInfo = nil
         context.delete(itemInCache)
         
         saveContext(subject: "Delete CMMessage Object")
         }
         }
         
         }
         }
         
         // Part2:
         // save data comes from server to the Cache
         var allMessages = [CMMessage]()
         
         for item in messages {
         let messageEntity = NSEntityDescription.entity(forEntityName: "CMMessage", in: context)
         let message = CMMessage(entity: messageEntity!, insertInto: context)
         
         message.delivered   = item.delivered as NSNumber?
         message.edited      = item.edited as NSNumber?
         message.id          = item.id as NSNumber?
         message.message     = item.message
         message.messageType = item.messageType
         message.metaData    = item.metaData
         message.ownerId     = item.ownerId as NSNumber?
         message.previousId  = item.previousId as NSNumber?
         message.seen        = item.seen as NSNumber?
         message.threadId    = item.threadId as NSNumber?
         message.time        = item.time as NSNumber?
         message.uniqueId    = item.uniqueId
         
         
         let theConversationEntity = NSEntityDescription.entity(forEntityName: "CMConversation", in: context)
         let theConversation = CMConversation(entity: theConversationEntity!, insertInto: context)
         theConversation.admin                   = item.conversation?.admin as NSNumber?
         theConversation.canEditInfo             = item.conversation?.canEditInfo as NSNumber?
         theConversation.canSpam                 = item.conversation?.canSpam as NSNumber?
         theConversation.descriptions            = item.conversation?.description
         theConversation.group                   = item.conversation?.group as NSNumber?
         theConversation.id                      = item.conversation?.id as NSNumber?
         theConversation.image                   = item.conversation?.image
         theConversation.joinDate                = item.conversation?.joinDate as NSNumber?
         theConversation.lastMessage             = item.conversation?.lastMessage
         theConversation.lastParticipantImage    = item.conversation?.lastParticipantImage
         theConversation.lastParticipantName     = item.conversation?.lastParticipantName
         theConversation.lastSeenMessageId       = item.conversation?.lastSeenMessageId as NSNumber?
         theConversation.metadata                = item.conversation?.metadata
         theConversation.mute                    = item.conversation?.mute as NSNumber?
         theConversation.participantCount        = item.conversation?.participantCount as NSNumber?
         theConversation.partner                 = item.conversation?.partner as NSNumber?
         theConversation.partnerLastDeliveredMessageId   = item.conversation?.partnerLastDeliveredMessageId as NSNumber?
         theConversation.partnerLastSeenMessageId        = item.conversation?.partnerLastSeenMessageId as NSNumber?
         theConversation.title                   = item.conversation?.title
         theConversation.time                    = item.conversation?.time as NSNumber?
         theConversation.type                    = item.conversation?.time as NSNumber?
         theConversation.unreadCount             = item.conversation?.unreadCount as NSNumber?
         
         message.conversation = theConversation
         
         
         let theForwardInfoEntity = NSEntityDescription.entity(forEntityName: "CMForwardInfo", in: context)
         let theForwardInfo = CMForwardInfo(entity: theForwardInfoEntity!, insertInto: context)
         let theForwardInfoParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theForwardInfoParticipant = CMParticipant(entity: theForwardInfoParticipantEntity!, insertInto: context)
         theForwardInfoParticipant.admin             = item.forwardInfo?.participant?.admin as NSNumber?
         theForwardInfoParticipant.blocked           = item.forwardInfo?.participant?.blocked as NSNumber?
         theForwardInfoParticipant.cellphoneNumber   = item.forwardInfo?.participant?.cellphoneNumber
         theForwardInfoParticipant.contactId         = item.forwardInfo?.participant?.contactId as NSNumber?
         theForwardInfoParticipant.coreUserId        = item.forwardInfo?.participant?.coreUserId as NSNumber?
         theForwardInfoParticipant.email             = item.forwardInfo?.participant?.email
         theForwardInfoParticipant.firstName         = item.forwardInfo?.participant?.firstName
         theForwardInfoParticipant.id                = item.forwardInfo?.participant?.id as NSNumber?
         theForwardInfoParticipant.image             = item.forwardInfo?.participant?.image
         theForwardInfoParticipant.lastName          = item.forwardInfo?.participant?.lastName
         theForwardInfoParticipant.myFriend          = item.forwardInfo?.participant?.myFriend as NSNumber?
         theForwardInfoParticipant.name              = item.forwardInfo?.participant?.name
         theForwardInfoParticipant.notSeenDuration   = item.forwardInfo?.participant?.notSeenDuration as NSNumber?
         theForwardInfoParticipant.online            = item.forwardInfo?.participant?.online as NSNumber?
         theForwardInfoParticipant.receiveEnable     = item.forwardInfo?.participant?.receiveEnable as NSNumber?
         theForwardInfoParticipant.sendEnable        = item.forwardInfo?.participant?.sendEnable as NSNumber?
         let theForwardInfoConversationEntity = NSEntityDescription.entity(forEntityName: "CMConversation", in: context)
         let theForwardInfoConversation = CMConversation(entity: theForwardInfoConversationEntity!, insertInto: context)
         theForwardInfoConversation.admin                   = item.forwardInfo?.conversation?.admin as NSNumber?
         theForwardInfoConversation.canEditInfo             = item.forwardInfo?.conversation?.canEditInfo as NSNumber?
         theForwardInfoConversation.canSpam                 = item.forwardInfo?.conversation?.canSpam as NSNumber?
         theForwardInfoConversation.descriptions            = item.forwardInfo?.conversation?.description
         theForwardInfoConversation.group                   = item.forwardInfo?.conversation?.group as NSNumber?
         theForwardInfoConversation.id                      = item.forwardInfo?.conversation?.id as NSNumber?
         theForwardInfoConversation.image                   = item.forwardInfo?.conversation?.image
         theForwardInfoConversation.joinDate                = item.forwardInfo?.conversation?.joinDate as NSNumber?
         theForwardInfoConversation.lastMessage             = item.forwardInfo?.conversation?.lastMessage
         theForwardInfoConversation.lastParticipantImage    = item.forwardInfo?.conversation?.lastParticipantImage
         theForwardInfoConversation.lastParticipantName     = item.forwardInfo?.conversation?.lastParticipantName
         theForwardInfoConversation.lastSeenMessageId       = item.forwardInfo?.conversation?.lastSeenMessageId as NSNumber?
         theForwardInfoConversation.metadata                = item.forwardInfo?.conversation?.metadata
         theForwardInfoConversation.mute                    = item.forwardInfo?.conversation?.mute as NSNumber?
         theForwardInfoConversation.participantCount        = item.forwardInfo?.conversation?.participantCount as NSNumber?
         theForwardInfoConversation.partner                 = item.forwardInfo?.conversation?.partner as NSNumber?
         theForwardInfoConversation.partnerLastDeliveredMessageId   = item.forwardInfo?.conversation?.partnerLastDeliveredMessageId as NSNumber?
         theForwardInfoConversation.partnerLastSeenMessageId        = item.forwardInfo?.conversation?.partnerLastSeenMessageId as NSNumber?
         theForwardInfoConversation.title                   = item.forwardInfo?.conversation?.title
         theForwardInfoConversation.time                    = item.forwardInfo?.conversation?.time as NSNumber?
         theForwardInfoConversation.type                    = item.forwardInfo?.conversation?.time as NSNumber?
         theForwardInfoConversation.unreadCount             = item.forwardInfo?.conversation?.unreadCount as NSNumber?
         
         theForwardInfo.participant = theForwardInfoParticipant
         theForwardInfo.conversation = theForwardInfoConversation
         
         message.forwardInfo = theForwardInfo
         
         
         let theParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theParticipant = CMParticipant(entity: theParticipantEntity!, insertInto: context)
         theParticipant.admin            = item.participant?.admin as NSNumber?
         theParticipant.blocked          = item.participant?.blocked as NSNumber?
         theParticipant.cellphoneNumber  = item.participant?.cellphoneNumber
         theParticipant.contactId        = item.participant?.contactId as NSNumber?
         theParticipant.coreUserId       = item.participant?.coreUserId as NSNumber?
         theParticipant.email            = item.participant?.email
         theParticipant.firstName        = item.participant?.firstName
         theParticipant.id               = item.participant?.id as NSNumber?
         theParticipant.image            = item.participant?.image
         theParticipant.lastName         = item.participant?.lastName
         theParticipant.myFriend         = item.participant?.myFriend as NSNumber?
         theParticipant.name             = item.participant?.name
         theParticipant.notSeenDuration  = item.participant?.notSeenDuration as NSNumber?
         theParticipant.online           = item.participant?.online as NSNumber?
         theParticipant.receiveEnable    = item.participant?.receiveEnable as NSNumber?
         theParticipant.sendEnable       = item.participant?.sendEnable as NSNumber?
         message.participant = theParticipant
         
         
         let theReplyInfoEntity = NSEntityDescription.entity(forEntityName: "CMReplyInfo", in: context)
         let theReplyInfo = CMReplyInfo(entity: theReplyInfoEntity!, insertInto: context)
         theReplyInfo.deletedd           = item.replyInfo?.deleted as NSNumber?
         theReplyInfo.repliedToMessageId = item.replyInfo?.repliedToMessageId as NSNumber?
         theReplyInfo.message            = item.replyInfo?.message
         theReplyInfo.messageType        = item.replyInfo?.messageType as NSNumber?
         theReplyInfo.metadata           = item.replyInfo?.metadata
         theReplyInfo.systemMetadata     = item.replyInfo?.systemMetadata
         let theReplyInfoParticipantEntity = NSEntityDescription.entity(forEntityName: "CMParticipant", in: context)
         let theReplyInfoParticipant = CMParticipant(entity: theReplyInfoParticipantEntity!, insertInto: context)
         theReplyInfoParticipant.admin            = item.replyInfo?.participant?.admin as NSNumber?
         theReplyInfoParticipant.blocked          = item.replyInfo?.participant?.blocked as NSNumber?
         theReplyInfoParticipant.cellphoneNumber  = item.replyInfo?.participant?.cellphoneNumber
         theReplyInfoParticipant.contactId        = item.replyInfo?.participant?.contactId as NSNumber?
         theReplyInfoParticipant.coreUserId       = item.replyInfo?.participant?.coreUserId as NSNumber?
         theReplyInfoParticipant.email            = item.replyInfo?.participant?.email
         theReplyInfoParticipant.firstName        = item.replyInfo?.participant?.firstName
         theReplyInfoParticipant.id               = item.replyInfo?.participant?.id as NSNumber?
         theReplyInfoParticipant.image            = item.replyInfo?.participant?.image
         theReplyInfoParticipant.lastName         = item.replyInfo?.participant?.lastName
         theReplyInfoParticipant.myFriend         = item.replyInfo?.participant?.myFriend as NSNumber?
         theReplyInfoParticipant.name             = item.replyInfo?.participant?.name
         theReplyInfoParticipant.notSeenDuration  = item.replyInfo?.participant?.notSeenDuration as NSNumber?
         theReplyInfoParticipant.online           = item.replyInfo?.participant?.online as NSNumber?
         theReplyInfoParticipant.receiveEnable    = item.replyInfo?.participant?.receiveEnable as NSNumber?
         theReplyInfoParticipant.sendEnable       = item.replyInfo?.participant?.sendEnable as NSNumber?
         theReplyInfo.participant = theReplyInfoParticipant
         
         message.replyInfo = theReplyInfo
         
         allMessages.append(message)
         }
         
         saveContext(subject: "Update Messages")
         }
         } catch {
         fatalError("Error on fetching list of CMConversation")
         }
         */
        
    }
    
    
    public func deleteMessage(count: Int?, fromTime: UInt?, messageId: Int?, offset: Int, order: String, query: String?, threadId: Int?, toTime: UInt?, uniqueId: String?) {
        let fetchRequest = retrieveMessageHistoryFetchRequest(firstMessageId: nil, fromTime: fromTime, messageId: messageId, lastMessageId: nil, order: order, query: query, threadId: threadId, toTime: toTime, uniqueId: uniqueId)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                
                switch (count) {
                case let .some(count):
                    var insideCount = 0
                    for (index, item) in result.enumerated() {
                        if (index >= offset) && (insideCount < count) {
                            
                            deleteMessage(inThread: Int(exactly: item.threadId ?? 0) ?? 0, withMessageIds: [Int(exactly: item.id ?? 0) ?? 0])
                            insideCount += 1
                        }
                    }
                case .none:
                    for item in result {
                        deleteMessage(inThread: Int(exactly: item.threadId ?? 0) ?? 0, withMessageIds: [Int(exactly: item.id ?? 0) ?? 0])
                    }
                    
                    //                default: break
                }
            }
            
        } catch {
            fatalError("Error on fetching list of CMMessage")
        }
    }
    
    
    
    // this function will save (or update) uploaded image response that comes from server, in the Cache.
    public func saveUploadImage(imageInfo: UploadImage, imageData: Data) {
        // check if there is any information about This Image File in the cache
        // if it has some data, it we will update that data,
        // otherwise we will create an object and save data on cache
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUploadImage")
        do {
            
            if let result = try context.fetch(fetchRequest) as? [CMUploadImage] {
                // if there is a value in this fetch request, it mean that we had already saved This Image info in the Cache.
                // so we just have to update that information with new response that comes from server
                
                // TODO: prevent copy one file in several places in the app - search by the Image file itself through the app bundle
                /*
                 if find sth, check out the information about that file:
                 if the info of both, was the same, just delete the fileInfo from cache, and then save it later
                 if the info was different, just save the new info in the cache and link it to this image file path
                 */
                
                // Part1:
                // find data that are exist in the Cache, (and the response request is containing that). and delete them
                for itemInCache in result {
                    if let imageId = Int(exactly: itemInCache.id ?? 0) {
                        if (imageId == imageInfo.id) {
                            // the uploadImage object that we are going to create, is already exist in the Cache
                            // to update information in this object:
                            // we will delete them first, then we will create it again later
                            
                            // delete the original file from local storage of the app, using path of the file
                            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                            
                            let myFilePath = path + "/\(fileSubPath.Images)/" + "\(imageInfo.id ?? 0)\(imageInfo.name ?? "default.png")"
                            // check if this file is exixt on the app bunde, then delete it
                            if FileManager.default.fileExists(atPath: myFilePath) {
                                do {
                                    try FileManager.default.removeItem(atPath: myFilePath)
                                } catch {
                                    fatalError("can not delete the image from app bundle!")
                                }
                            }
                            
                            // delete the information from cache
                            context.delete(itemInCache)
                            saveContext(subject: "Delete CMUploadImage Object")
                        }
                    }
                }
                
                // Part2:
                // save data comes from server to the Cache
                let theUploadImageEntity = NSEntityDescription.entity(forEntityName: "CMUploadImage", in: context)
                let theUploadImage = CMUploadImage(entity: theUploadImageEntity!, insertInto: context)
                
                theUploadImage.actualHeight = imageInfo.actualHeight as NSNumber?
                theUploadImage.actualWidth  = imageInfo.actualWidth as NSNumber?
                theUploadImage.hashCode     = imageInfo.hashCode
                theUploadImage.height       = imageInfo.height as NSNumber?
                theUploadImage.id           = imageInfo.id as NSNumber?
                theUploadImage.name         = imageInfo.name
                theUploadImage.width        = imageInfo.width as NSNumber?
                
                // save file on app bundle
                //                guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else { return }
                let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                let directoryURL = URL(fileURLWithPath: directoryPath)
                do {
                    try imageData.write(to: directoryURL.appendingPathComponent("\(fileSubPath.Images)/\(imageInfo.id ?? 0)\(imageInfo.name ?? "default")"))
                } catch {
                    print(error.localizedDescription)
                }
                
                saveContext(subject: "Update UploadImage")
            }
        } catch {
            fatalError("Error on fetching list of Conversations")
        }
        
    }
    
    
    // this function will save (or update) uploaded image response that comes from server, in the Cache.
    public func saveUploadFile(fileInfo: UploadFile, fileData: Data) {
        // check if there is any information about This Image File in the cache
        // if it has some data, it we will update that data,
        // otherwise we will create an object and save data on cache
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUploadFile")
        do {
            
            if let result = try context.fetch(fetchRequest) as? [CMUploadFile] {
                // if there is a value in this fetch request, it mean that we had already saved This Image info in the Cache.
                // so we just have to update that information with new response that comes from server
                
                // TODO: prevent copy one file in several places in the app - search by the Image file itself through the app bundle
                /*
                 if find sth, check out the information about that file:
                 if the info of both, was the same, just delete the fileInfo from cache, and then save it later
                 if the info was different, just save the new info in the cache and link it to this image file path
                 */
                
                // Part1:
                // find data that are exist in the Cache, (and the response request is containing that). and delete them
                for itemInCache in result {
                    if let fileId = Int(exactly: itemInCache.id ?? 0) {
                        if (fileId == fileInfo.id) {
                            // the uploadFile object that we are going to create, is already exist in the Cache
                            // to update information in this object:
                            // we will delete them first, then we will create it again later
                            
                            // delete the original file from local storage of the app, using path of the file
                            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                            let myFilePath = path + "/\(fileSubPath.Files)/" + "\(fileInfo.id ?? 0)\(fileInfo.name ?? "default")"
                            
                            if FileManager.default.fileExists(atPath: myFilePath) {
                                do {
                                    try FileManager.default.removeItem(atPath: myFilePath)
                                } catch {
                                    fatalError("can not delete the image from app bundle!")
                                }
                            }
                            
                            // delete the information from cache
                            context.delete(itemInCache)
                            saveContext(subject: "Delete CMUploadFile Object")
                        }
                    }
                }
                
                // Part2:
                // save data comes from server to the Cache
                let theUploadFileEntity = NSEntityDescription.entity(forEntityName: "CMUploadFile", in: context)
                let theUploadFile = CMUploadFile(entity: theUploadFileEntity!, insertInto: context)
                
                theUploadFile.hashCode      = fileInfo.hashCode
                theUploadFile.id            = fileInfo.id as NSNumber?
                theUploadFile.name          = fileInfo.name
                
                // save file on app bundle
                let directoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                let directoryURL = URL(fileURLWithPath: directoryPath)
                do {
                    try fileData.write(to: directoryURL.appendingPathComponent("\(fileSubPath.Files)/\(fileInfo.id ?? 0)\(fileInfo.name ?? "default")"))
                } catch {
                    print(error.localizedDescription)
                }
                
                saveContext(subject: "Update UploadFile")
            }
        } catch {
            fatalError("Error on fetching list of Conversations")
        }
        
    }
    
    
    // delete contacts thas has removed from server
    //    public func updateCMContactEntityByDeletingRemovedContactsFromServer(allServerContacts: [Contact]) {
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
    //        do {
    //            if let result = try context.fetch(fetchRequest) as? [CMContact] {
    //                for cmcontact in result {    // loop through the CMContacts (Contacts in the cache)
    //                    var shouldDelete = false
    //                    for contact in allServerContacts {
    //                        if (cmcontact.id! == (contact.id! as NSNumber)) {
    //                            shouldDelete = true
    //                        }
    //                    }
    //                    if shouldDelete {
    //                        deleteContact(withContactIds: [Int(exactly: cmcontact.id!)!])
    //                    }
    //                }
    //            }
    //        } catch {
    //
    //        }
    //    }
    
    // delete contact
    public func deleteContact(withContactIds contactIds: [Int])  {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                for id in contactIds {
                    for itemInCache in result {
                        if let contactId = Int(exactly: itemInCache.id ?? 0) {
                            if (contactId == id) {
                                if let _ = itemInCache.linkedUser {
                                    context.delete(itemInCache.linkedUser!)
                                }
                                context.delete(itemInCache)
                                saveContext(subject: "Delete CMContact Object")
                            }
                        }
                    }
                }
                saveContext(subject: "Update CMContact")
            }
        } catch {
            fatalError("Error on fetching list of CMContact when trying to delete contact...")
        }
    }
    
    
    // delete the participant itself
    public func deleteParticipant(withParticipantIds participantIds: [Int]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                
                // Part1:
                // find data that are exist in the Cache, (and the response request is containing that). and delete them
                for id in participantIds {
                    for itemInCache in result {
                        if let participantId = Int(exactly: itemInCache.id ?? 0) {
                            if (participantId == id) {
                                context.delete(itemInCache)
                                saveContext(subject: "Delete CMParticipant Object")
                            }
                        }
                    }
                }
            }
        } catch {
            fatalError("Error on fetching list of CMParticipant when trying to delete Participant")
        }
    }
    
    
    // delete participants from specific thread
    public func deleteParticipant(inThread: Int, withParticipantIds participantIds: [Int]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        fetchRequest.predicate = NSPredicate(format: "id == %i", inThread)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                if (result.count > 0) {
                    if let _ = result.first!.participants {
                        for participant in result.first!.participants! {
                            for id in participantIds {
                                if (Int(exactly: participant.id ?? 0) == id) {
                                    context.delete(participant)
                                    saveContext(subject: "Delete CMParticipant Object from Thread")
                                }
                            }
                        }
                    }
                }
                saveContext(subject: "Update CMConversation")
            }
        } catch {
            fatalError("Error on fetching list of CMConversation when trying to delete some Participant from it")
        }
    }
    
    
    // delete messages from specific thread
    public func deleteMessage(inThread: Int, withMessageIds messageIds: [Int]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        fetchRequest.predicate = NSPredicate(format: "threadId == %i", inThread)
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                for message in result {
                    for msgId in messageIds {
                        if (Int(exactly: message.id ?? 0) == msgId) {
                            if let _ = message.participant {
                                context.delete(message.participant!)
                                saveContext(subject: "Delete participant from CMMessage Object")
                            }
                            if let _ = message.conversation {
                                context.delete(message.conversation!)
                                saveContext(subject: "Delete conversation from CMMessage Object")
                            }
                            if let _ = message.replyInfo {
                                context.delete(message.replyInfo!)
                                saveContext(subject: "Delete replyInfo from CMMessage Object")
                            }
                            if let _ = message.forwardInfo {
                                context.delete(message.forwardInfo!)
                                saveContext(subject: "Delete forwardInfo from CMMessage Object")
                            }
                            context.delete(message)
                            saveContext(subject: "Delete CMMessage Object")
                        }
                    }
                }
                saveContext(subject: "Update CMMessage")
            }
        } catch {
            fatalError("Error on fetching list of CMMessage when trying to delete")
        }
    }
    
    
    
    
    
    
    // delete objects that has been not updated for "timeStamp" seconds
    func deleteThreadParticipants(timeStamp: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMThreadParticipants")
        let currentTime = Int(Date().timeIntervalSince1970)
        fetchRequest.predicate = NSPredicate(format: "time <= %i", Int(currentTime - timeStamp))
        
        print("currentTime = \(currentTime)\t timeStamp = \(timeStamp)")
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMThreadParticipants] {
                print("fetched successfully")
                for item in result {
                    print("there are = \(result.count)")
                    print("time = \(item.time!)")
                    deleteParticipant(inThread: Int(exactly: item.threadId!)!, withParticipantIds: [Int(exactly: item.participantId!)!])
                    print("first delete")
                    context.delete(item)
                    print("second delete")
                    saveContext(subject: "item Deleted from CMThreadParticipants")
                }
            }
        } catch {
            fatalError("Error on fetching CMThreadParticipants when trying to delete object based on timeStamp")
        }
    }
    
    
    // delete objects that has been not updated for "timeStamp" seconds
    func deleteContacts(byTimeStamp timeStamp: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        let currentTime = Int(Date().timeIntervalSince1970)
        fetchRequest.predicate = NSPredicate(format: "time <= %i", Int(currentTime - timeStamp))
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                for item in result {
                    deleteContact(withContactIds: [Int(exactly: item.id!)!])
                    context.delete(item)
                    saveContext(subject: "item Deleted from CMContact")
                }
            }
        } catch {
            fatalError("Error on fetching CMContact when trying to delete object based on timeStamp")
        }
    }
    
    
    
    public func deleteAllCMLinkedUsersFromCache() {
        let fetchLinkeUsers = NSFetchRequest<NSFetchRequestResult>(entityName: "CMLinkedUser")
        do {
            if let result = try context.fetch(fetchLinkeUsers) as? [CMLinkedUser] {
                for linkeUser in result {
                    deleteAndSave(object: linkeUser, withMessage: "CMLinkedUser Deleted")
                }
            }
        } catch {
            fatalError()
        }
    }
    
    public func deleteAllContactsFromCache() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                for contact in result {
                    if let lui = contact.linkedUser {
                        print("id = \(lui)")
                        context.delete(contact.linkedUser!)
                    }
                    deleteAndSave(object: contact, withMessage: "CMContact Deleted.")
                }
            }
        } catch {
            fatalError()
        }
    }
    
    public func deleteAllThreadsFromCache() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                for thread in result {
                    if (thread.inviter != nil) {
                        deleteAndSave(object: thread.inviter!, withMessage: "inviter from CMConversation Deleted.")
                    }
                    if (thread.lastMessageVO != nil) {
                        deleteAndSave(object: thread.lastMessageVO!, withMessage: "lastMessageVO from CMConversation Deleted.")
                    }
                    if let threadParticipants = thread.participants {
                        for participant in threadParticipants {
                            deleteAndSave(object: participant, withMessage: "participant from CMConversation Deleted.")
                        }
                    }
                    deleteAndSave(object: thread, withMessage: "CMConversation Deleted.")
                }
            }
        } catch {
            fatalError()
        }
    }
    
    public func deleteAllMessagesFromCache() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                for message in result {
                    if (message.participant != nil) {
                        deleteAndSave(object: message.participant!, withMessage: "participant from CMMessage Deleted")
                    }
                    if (message.forwardInfo != nil) {
                        deleteAndSave(object: message.forwardInfo!, withMessage: "forwardInfo from CMMessage Deleted")
                    }
                    if (message.replyInfo != nil) {
                        deleteAndSave(object: message.replyInfo!, withMessage: "replyInfo from CMMessage Deleted")
                    }
                    if (message.conversation != nil) {
                        deleteAndSave(object: message.conversation!, withMessage: "conversation from CMMessage Deleted")
                    }
                    deleteAndSave(object: message, withMessage: "CMMessage Deleted.")
                }
            }
        } catch {
            fatalError()
        }
    }
    
    public func deleteUserInfoFromCache() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUser")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMUser] {
                for user in result {
                    deleteAndSave(object: user, withMessage: "CMUser Deleted.")
                }
            }
        } catch {
            fatalError()
        }
    }
    
    public func deleteAllImagesFromCache() {
        
    }
    
    public func deleteAllFilesFromCache() {
        
    }
    
    public func deleteThreadParticipantsTableFromCache() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMThreadParticipants")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMThreadParticipants] {
                for row in result {
                    deleteAndSave(object: row, withMessage: "Delete row from CMThreadParticipants table")
                }
            }
        } catch {
            fatalError()
        }
    }
    
    public func deleteCacheData() {
        deleteAllCMLinkedUsersFromCache()
        deleteAllContactsFromCache()
        deleteAllThreadsFromCache()
        deleteAllMessagesFromCache()
        deleteUserInfoFromCache()
        deleteAllImagesFromCache()
        deleteAllFilesFromCache()
        deleteThreadParticipantsTableFromCache()
    }
    
}







// MARK: - Functions that will retrieve data from CoreData Cache

extension Cache {
    
    /*
     retrieve userInfo data from Cache
     if it found any data from UserInfo in the Cache DB, it will return that,
     otherwise it will return nil. (means cache has no data on itself)
     */
    public func retrieveUserInfo() -> UserInfoModel? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUser")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMUser] {
                if (result.count > 0) {
                    let user = User(cellphoneNumber:    result.first!.cellphoneNumber,
                                    email:              result.first!.email,
                                    id:                 Int(exactly: result.first!.id ?? 0),
                                    image:              result.first!.image,
                                    lastSeen:           Int(exactly: result.first!.lastSeen ?? 0),
                                    name:               result.first!.name,
                                    receiveEnable:      Bool(exactly: result.first!.receiveEnable ?? true),
                                    sendEnable:         Bool(exactly: result.first!.sendEnable ?? true))
                    let userInfoModel = UserInfoModel(userObject: user, hasError: false, errorMessage: "", errorCode: 0)
                    return userInfoModel
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMUser")
        }
    }
    
    /*
     retrieve Threads from Cache
     if it found any data from Threads in the Cache DB, it will return that,
     otherwise it will return nil. (means cache has no data on itself).
     .
     first, it will fetch the Objects from CoreData, and sort them by time.
     then based on the client request, it will find the objects that the client want to get,
     and then it will return it as an array of 'Conversation' to the client.
     */
    // TODO: - Have to implement search in threads by using 'name' and also 'threadIds' properties!
    public func retrieveThreads(ascending:  Bool,
                                count:      Int,
                                name:       String?,
                                offset:     Int,
                                threadIds:  [Int]?,
                                timeStamp:  Int) -> GetThreadsModel? {
        
        deleteThreadParticipants(timeStamp: timeStamp)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        
        // use this array to make logical or for threads
        var fetchPredicatArray = [NSPredicate]()
        // put the search statement on the predicate to search throut the Conversations(Threads)
        if let searchStatement = name {
            if (searchStatement != "") {
                let searchTitle = NSPredicate(format: "title CONTAINS[cd] %@", searchStatement)
                let searchDescriptions = NSPredicate(format: "descriptions CONTAINS[cd] %@", searchStatement)
                fetchPredicatArray.append(searchTitle)
                fetchPredicatArray.append(searchDescriptions)
            }
        }
        
        // loop through the threadIds Arr that the user seends, and fill the 'fetchPredicatArray' property to predicate
        if let searchThreadId = threadIds {
            for i in searchThreadId {
                let threadIdPredicate = NSPredicate(format: "id == %i", i)
                fetchPredicatArray.append(threadIdPredicate)
            }
        }
        
        if (fetchPredicatArray.count > 0) {
            let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: fetchPredicatArray)
            fetchRequest.predicate = predicateCompound
        }
        
        // sort the result by the time
        let sortByTime = NSSortDescriptor(key: "time", ascending: ascending)
        fetchRequest.sortDescriptors = [sortByTime]
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                print("fetch CMConversation: \(result.count)")
                var insideCount = 0
                var cmConversationObjectArr = [CMConversation]()
                for (index, item) in result.enumerated() {
                    if (index >= offset) && (insideCount < count) {
                        print("item added to the response Array")
                        cmConversationObjectArr.append(item)
                        insideCount += 1
                    }
                }
                
                var conversationArr = [Conversation]()
                for item in cmConversationObjectArr {
                    let conversationObject = item.convertCMConversationToConversationObject()
                    conversationArr.append(conversationObject)
                }
                
                let getThreadModelResponse = GetThreadsModel(conversationObjects: conversationArr,
                                                             contentCount:  conversationArr.count,
                                                             count:         count,
                                                             offset:        offset,
                                                             hasError:      false,
                                                             errorMessage:  "",
                                                             errorCode:     0)
                
                return getThreadModelResponse
                
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMConversation")
        }
    }
    
    /*
     retrieve Contacts data from Cache
     if it found any data from Cache DB, it will return that,
     otherwise it will return nil. (means cache has no data on itself)
     .
     first, it will fetch the Objects from CoreData.
     then based on the client request, it will find the objects that the client want to get,
     and then it will return it as an array of 'Contact' to the client.
     */
    // TODO: - Have to implement search in contacts by using 'name' property!
    public func retrieveContacts(ascending:         Bool,
                                 cellphoneNumber:   String?,
                                 count:             Int,
                                 email:             String?,
                                 firstName:         String?,
                                 id:                Int?,
                                 lastName:          String?,
                                 offset:            Int,
                                 search:            String?,
                                 timeStamp:         Int,
                                 uniqueId:          String?) -> GetContactsModel? {
        
        deleteContacts(byTimeStamp: timeStamp)
        
        /*
         + if 'id' or 'uniqueId' property have been set:
         we only have to predicate of them and answer exact response
         
         + in the other situation:
         make this properties AND together: 'firstName', 'lastName', 'cellphoneNumber', 'email'
         then with the response of the AND, make OR with 'search' property
         
         then we create the output model and return it.
         */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        
        // check if 'id' or 'uniqueId' had been set
        let theOnlyPredicate: NSPredicate?
        if let theId = id {
            theOnlyPredicate = NSPredicate(format: "id == %i", theId)
            fetchRequest.predicate = theOnlyPredicate
        } else if let theUniqueId = uniqueId {
            theOnlyPredicate = NSPredicate(format: "uniqueId == %@", theUniqueId)
            fetchRequest.predicate = theOnlyPredicate
        } else {
            
            var andPredicateArr = [NSPredicate]()
            if let theCellphoneNumber = cellphoneNumber {
                if (theCellphoneNumber != "") {
                    let theCellphoneNumberPredicate = NSPredicate(format: "cellphoneNumber CONTAINS[cd] %@", theCellphoneNumber)
                    andPredicateArr.append(theCellphoneNumberPredicate)
                }
            }
            if let theFirstName = firstName {
                if (theFirstName != "") {
                    let theFirstNamePredicate = NSPredicate(format: "firstName CONTAINS[cd] %@", theFirstName)
                    andPredicateArr.append(theFirstNamePredicate)
                }
            }
            if let theLastName = lastName {
                if (theLastName != "") {
                    let theLastNamePredicate = NSPredicate(format: "lastName CONTAINS[cd] %@", theLastName)
                    andPredicateArr.append(theLastNamePredicate)
                }
            }
            if let theEmail = email {
                if (theEmail != "") {
                    let theEmailPredicate = NSPredicate(format: "email CONTAINS[cd] %@", theEmail)
                    andPredicateArr.append(theEmailPredicate)
                }
            }
            
            var orPredicatArray = [NSPredicate]()
            
            if (andPredicateArr.count > 0) {
                let andPredicateCompound = NSCompoundPredicate(type: .and, subpredicates: andPredicateArr)
                orPredicatArray.append(andPredicateCompound)
            }
            
            
            if let searchStatement = search {
                if (searchStatement != "") {
                    let theSearchPredicate = NSPredicate(format: "cellphoneNumber CONTAINS[cd] %@ OR email CONTAINS[cd] %@ OR firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", searchStatement, searchStatement, searchStatement, searchStatement)
                    orPredicatArray.append(theSearchPredicate)
                }
            }
            
            if (orPredicatArray.count > 0) {
                let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: orPredicatArray)
                fetchRequest.predicate = predicateCompound
            }
        }
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMContact] {
                
                var insideCount = 0
                var cmContactObjectArr = [CMContact]()
                
                for (index, item) in result.enumerated() {
                    if (index >= offset) && (insideCount < count) {
                        cmContactObjectArr.append(item)
                        insideCount += 1
                    }
                }
                
                var contactsArr = [Contact]()
                for item in cmContactObjectArr {
                    contactsArr.append(item.convertCMContactToContactObject())
                }
                
                let getContactModelResponse = GetContactsModel(contactsObject:  contactsArr,
                                                               contentCount:    contactsArr.count,
                                                               count:           count,
                                                               offset:          offset,
                                                               hasError:        false,
                                                               errorMessage:    "",
                                                               errorCode:       0)
                
                return getContactModelResponse
                
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMContact")
        }
    }
    
    /*
     retrieve ThreadParticipants data from Cache
     if it found any data from Cache DB, it will return that,
     otherwise it will return nil. (means cache has no data on itself)
     .
     first, it will fetch the Objects from CoreData.
     then based on the client request, it will find the objects that the client want to get,
     and then it will return it as an array of 'Participant' to the client.
     */
    public func retrieveThreadParticipants(ascending:   Bool,
                                           count:       Int,
                                           offset:      Int,
                                           threadId:    Int,
                                           timeStamp:   Int) -> GetThreadParticipantsModel? {
        
        deleteThreadParticipants(timeStamp: timeStamp)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "id == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                if (result.count > 0) {
                    let thread = result.first!
                    if let threadParticipants = thread.participants {
                        var insideCount = 0
                        var cmParticipantObjectArr = [CMParticipant]()
                        
                        for (index, item) in threadParticipants.enumerated() {
                            if (index >= offset) && (insideCount < count) {
                                cmParticipantObjectArr.append(item)
                                insideCount += 1
                            }
                        }
                        
                        var participantsArr = [Participant]()
                        for item in cmParticipantObjectArr {
                            participantsArr.append(item.convertCMParticipantToParticipantObject())
                        }
                        let getThreadParticipantModelResponse = GetThreadParticipantsModel(participantObjects: participantsArr,
                                                                                           contentCount: 0,
                                                                                           count: count,
                                                                                           offset: offset,
                                                                                           hasError: false,
                                                                                           errorMessage: "",
                                                                                           errorCode: 0)
                        
                        return getThreadParticipantModelResponse
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMParticipant")
        }
    }
    
    
    public func retrievePhoneContacts() -> [Contact]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhoneContact")
        do {
            if let result = try context.fetch(fetchRequest) as? [PhoneContact] {
                if (result.count > 0) {
                    
                    var contactsArr = [Contact]()
                    for item in result {
                        let contact = Contact(cellphoneNumber: item.cellphoneNumber, email: item.email, firstName: item.firstName, hasUser: false, id: nil, image: nil, lastName: item.lastName, linkedUser: nil, notSeenDuration: nil, timeStamp: nil, uniqueId: nil, userId: nil)
                        contactsArr.append(contact)
                    }
                    
                    return contactsArr
                }
            }
        } catch {
            
        }
        return nil
    }
    
    
    /*
     retrieve MessageHistory data from Cache
     if it found any data from Cache DB, it will return that,
     otherwise it will return nil. (means cache has no relevent data on itself)
     .
     first, it will fetch the Objects from CoreData.
     then based on the client request, it will find the objects that the client want to get,
     and then it will return it as an array of 'Message' to the client.
     */
    public func retrieveMessageHistory(count:           Int,
                                       firstMessageId:  Int?,
                                       fromTime:        UInt?,
                                       lastMessageId:   Int?,
                                       messageId:       Int?,
                                       offset:          Int,
                                       order:           String?,
                                       query:           String?,
                                       threadId:        Int,
                                       toTime:          UInt?,
                                       uniqueId:        String?) -> GetHistoryModel? {
        /*
         first we have to make AND of these 2 properties: 'firstMessageId' AND 'lastMessageId'.
         then make them OR with 'query' property.
         ( (firstMessageId AND lastMessageId) OR query )
         after that, we will order them by the time, then based on the 'count' and 'offset' properties,
         we create the output model and return it.
         after all we only have to show messages that blongs to the 'threadId' property,
         so we AND the result of last operation with 'threadId' property.
         */
        let fetchRequest = retrieveMessageHistoryFetchRequest(firstMessageId: firstMessageId, fromTime: fromTime, messageId: messageId, lastMessageId: lastMessageId, order: order, query: query, threadId: threadId, toTime: toTime, uniqueId: uniqueId)
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMMessage] {
                var insideCount = 0
                var cmMessageObjectArr = [CMMessage]()
                
                for (index, item) in result.enumerated() {
                    if (index >= offset) && (insideCount < count) {
                        cmMessageObjectArr.append(item)
                        insideCount += 1
                    }
                }
                
                var messageArr = [Message]()
                for item in cmMessageObjectArr {
                    messageArr.append(item.convertCMMessageToMessageObject())
                }
                
                let getMessageModelResponse = GetHistoryModel(messageContent: messageArr,
                                                              contentCount: messageArr.count,
                                                              count: count,
                                                              offset: offset,
                                                              hasError: false,
                                                              errorMessage: "",
                                                              errorCode: 0)
                
                return getMessageModelResponse
                
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMMessage")
        }
    }
    
    
    func retrieveMessageHistoryFetchRequest(firstMessageId: Int?, fromTime: UInt?, messageId: Int?, lastMessageId: Int?, order: String?, query: String?, threadId: Int?, toTime: UInt?, uniqueId: String?) -> NSFetchRequest<NSFetchRequestResult> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        
        // sort the result by the time
        if let resultOrder = order {
            if (resultOrder == Ordering.ascending.rawValue) {
                let sortByTime = NSSortDescriptor(key: "time", ascending: true)
                fetchRequest.sortDescriptors = [sortByTime]
            }
        } else {
            let sortByTime = NSSortDescriptor(key: "time", ascending: false)
            fetchRequest.sortDescriptors = [sortByTime]
        }
        
        
        switch (messageId, uniqueId, threadId, firstMessageId, lastMessageId, fromTime, toTime, query) {
            
        // if messageId is set, just search for message that has this exact messageId
        case let (.some(myMessageId), _, _, _, _, _, _, _):
            fetchRequest.predicate = NSPredicate(format: "id == %i", myMessageId)
            
        // if uniqueId is set, just search for message that has this exact uniqueId
        case let ( _, .some(myUniqueId), _, _, _, _, _, _):
            fetchRequest.predicate = NSPredicate(format: "uniqueId == %@", myUniqueId)
            
        // check if there was any parameter has been set, and put it's predicate statement on an array, then AND them all
        case let (.none, .none, threadId, firstMagId, lastMagId, fromTime, toTime, query):
            
            var predicateArray = [NSPredicate]()
            
            if let thId = threadId {
                predicateArray.append(NSPredicate(format: "threadId == %i", thId))
            }
            if let fTime = fromTime {
                predicateArray.append(NSPredicate(format: "time >= %i", fTime))
            }
            if let tTime = toTime {
                predicateArray.append(NSPredicate(format: "time <= %i", tTime))
            }
            if let fMsg = firstMagId {
                predicateArray.append(NSPredicate(format: "id >= %i", fMsg))
            }
            if let lMsg = lastMagId {
                predicateArray.append(NSPredicate(format: "id <= %i", lMsg))
            }
            if let searchQuery = query {
                if (searchQuery != "") {
                    predicateArray.append(NSPredicate(format: "message CONTAINS[cd] %@", searchQuery))
                }
            }
            
            if (predicateArray.count > 0) {
                let myAndCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicateArray)
                fetchRequest.predicate = myAndCompoundPredicate
            }
            
        }
        
        
        //        // this predicate used to get messages that are in the specific thread using 'threadId' property
        //        let threadIdPredicate = NSPredicate(format: "threadId == %i", threadId)
        //        //        fetchRequest.predicate = threadPredicate
        //        var finalPredicate: [NSPredicate] = [threadIdPredicate]
        //
        //
        //        // AND predicate for 'firstMessageId' AND 'lastMessageId'
        //        var andFirstIdToLastIdPiredicateArr = [NSPredicate]()
        //        if let first = firstMessageId {
        //            let firstPredicate = NSPredicate(format: "id >= %i", first)
        //            andFirstIdToLastIdPiredicateArr.append(firstPredicate)
        //        }
        //        if let last = lastMessageId {
        //            let lastPredicate = NSPredicate(format: "id <= %i", last)
        //            andFirstIdToLastIdPiredicateArr.append(lastPredicate)
        //        }
        //
        //        // use this array to make logical OR between the result of the 'firstANDlastCompound' and 'query'
        //        var searchPredicatArray = [NSPredicate]()
        //
        //        if (andFirstIdToLastIdPiredicateArr.count > 0) {
        //            let firstANDlastCompound = NSCompoundPredicate(type: .and, subpredicates: andFirstIdToLastIdPiredicateArr)
        //            searchPredicatArray.append(firstANDlastCompound)
        //        }
        //
        //
        //        // put the search statement on the predicate to search through the Messages
        //        if let searchStatement = query {
        //            if (searchStatement != "") {
        //                let searchMessages = NSPredicate(format: "message CONTAINS[cd] %@", searchStatement)
        //                searchPredicatArray.append(searchMessages)
        //            }
        //        }
        //
        //
        //
        //        if (searchPredicatArray.count > 0) {
        //            let queryORfirstlastCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: searchPredicatArray)
        //            finalPredicate.append(queryORfirstlastCompound)
        //        }
        //
        //        let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: finalPredicate)
        //        fetchRequest.predicate = predicateCompound
        
        return fetchRequest
    }
    
    
    
    /*
     retrieve UploadImage data from Cache
     if it found any data from Cache DB, it will return that,
     otherwise it will return nil. (means cache has no relevent data on itself)
     .
     first, it will fetch the Objects from CoreData.
     then based on the client request, it will find the objects that the client want to get,
     and then it will return it as 'UploadImageModel' model to the client.
     */
    public func retrieveUploadImage(hashCode:   String,
                                    imageId:    Int) -> (UploadImageModel, String)? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUploadImage")
        let searchImage = NSPredicate(format: "hashCode == %@ AND id == %i", hashCode, imageId)
        fetchRequest.predicate = searchImage
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMUploadImage] {
                print("found items = \(result.count)")
                if let firstObject = result.first {
                    let imageObject = firstObject.convertCMUploadImageToUploadImageObject()
                    let uploadImageModel = UploadImageModel(messageContentModel: imageObject,
                                                            errorCode: 0,
                                                            errorMessage: "",
                                                            hasError: false)
                    
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let myFilePath = path + "/\(fileSubPath.Images)/" + "\(firstObject.id ?? 0)\(firstObject.name ?? "default.png")"
                    
                    return (uploadImageModel, myFilePath)
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMUploadImage")
        }
    }
    
    
    /*
     retrieve UploadFile data from Cache
     if it found any data from Cache DB, it will return that,
     otherwise it will return nil. (means cache has no relevent data on itself)
     .
     first, it will fetch the Objects from CoreData.
     then based on the client request, it will find the objects that the client want to get,
     and then it will return it as 'UploadImageModel' model to the client.
     */
    public func retrieveUploadFile(fileId:      Int,
                                   hashCode:    String) -> (UploadFileModel, String)? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUploadFile")
        let searchFile = NSPredicate(format: "hashCode == %@ AND id == %i", hashCode, fileId)
        fetchRequest.predicate = searchFile
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMUploadFile] {
                
                if let firstObject = result.first {
                    let fileObject = firstObject.convertCMUploadFileToUploadFileObject()
                    let uploadFileModel = UploadFileModel(messageContentModel: fileObject,
                                                          errorCode: 0,
                                                          errorMessage: "",
                                                          hasError: false)
                    
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let myFilePath = path + "/\(fileSubPath.Files)/" + "\(firstObject.id ?? 0)\(firstObject.name ?? "default")"
                    
                    return (uploadFileModel, myFilePath)
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of CMUploadFile")
        }
    }
    
    
}






// handle Queue of wait messages
extension Cache {
    
    func saveTextMessageToWaitQueue(textMessage: QueueOfWaitTextMessagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfTextMessages", in: context)
        let messageToSaveOnQueue = QueueOfTextMessages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.content        = textMessage.content
        messageToSaveOnQueue.repliedTo      = textMessage.repliedTo as NSNumber?
        messageToSaveOnQueue.threadId       = textMessage.threadId as NSNumber?
        messageToSaveOnQueue.typeCode       = textMessage.typeCode
        messageToSaveOnQueue.uniqueId       = textMessage.uniqueId
        
        if let metaData2 = textMessage.metaData {
            NSObject.convertJSONtoTransformable(dataToStore: metaData2) { (data) in
                messageToSaveOnQueue.metaData = data
            }
        }
        
        if let systemMetadata2 = textMessage.systemMetadata {
            NSObject.convertJSONtoTransformable(dataToStore: systemMetadata2) { (data) in
                messageToSaveOnQueue.systemMetadata = data
            }
        }
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfTextMessages -create a new object-")
    }
    
    func saveFileMessageToWaitQueue(fileMessage: QueueOfWaitFileMessagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfFileMessages", in: context)
        let messageToSaveOnQueue = QueueOfFileMessages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.content        = fileMessage.content
        messageToSaveOnQueue.fileName       = fileMessage.fileName
        messageToSaveOnQueue.fileToSend     = fileMessage.fileToSend as NSData?
        messageToSaveOnQueue.imageName      = fileMessage.imageName
        messageToSaveOnQueue.imageToSend    = fileMessage.imageToSend as NSData?
        messageToSaveOnQueue.repliedTo      = fileMessage.repliedTo as NSNumber?
        messageToSaveOnQueue.subjectId      = fileMessage.subjectId as NSNumber?
        messageToSaveOnQueue.threadId       = fileMessage.threadId as NSNumber?
        messageToSaveOnQueue.typeCode       = fileMessage.typeCode
        messageToSaveOnQueue.uniqueId       = fileMessage.uniqueId
        messageToSaveOnQueue.hC             = fileMessage.hC
        messageToSaveOnQueue.wC             = fileMessage.wC
        messageToSaveOnQueue.xC             = fileMessage.xC
        messageToSaveOnQueue.yC             = fileMessage.yC
        
        if let metaData2 = fileMessage.metaData {
            NSObject.convertJSONtoTransformable(dataToStore: metaData2) { (data) in
                messageToSaveOnQueue.metaData = data
            }
        }
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfFileMessages -create a new object-")
    }
    
    func saveUploadImageToWaitQueue(image: QueueOfWaitUploadImagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfUploadImages", in: context)
        let messageToSaveOnQueue = QueueOfUploadImages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.dataToSend     = image.dataToSend as NSData?
        messageToSaveOnQueue.fileExtension  = image.fileExtension
        messageToSaveOnQueue.fileName       = image.fileName
        messageToSaveOnQueue.fileSize       = image.fileSize as NSNumber?
        messageToSaveOnQueue.originalFileName = image.originalFileName
        messageToSaveOnQueue.threadId       = image.threadId as NSNumber?
        messageToSaveOnQueue.uniqueId       = image.uniqueId
        messageToSaveOnQueue.xC             = image.xC as NSNumber?
        messageToSaveOnQueue.yC             = image.yC as NSNumber?
        messageToSaveOnQueue.hC             = image.hC as NSNumber?
        messageToSaveOnQueue.wC             = image.wC as NSNumber?
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfImages -create a new object-")
    }
    
    func saveUploadFileToWaitQueue(file: QueueOfWaitUploadFilesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfUploadFiles", in: context)
        let messageToSaveOnQueue = QueueOfUploadFiles(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.dataToSend     = file.dataToSend as NSData?
        messageToSaveOnQueue.fileExtension  = file.fileExtension
        messageToSaveOnQueue.fileName       = file.fileName
        messageToSaveOnQueue.fileSize       = file.fileSize as NSNumber?
        messageToSaveOnQueue.originalFileName = file.originalFileName
        messageToSaveOnQueue.threadId       = file.threadId as NSNumber?
        messageToSaveOnQueue.uniqueId       = file.uniqueId
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfUploadFiles -create a new object-")
    }
    
    func saveEditMessageToWaitQueue(editMessage: QueueOfWaitEditMessagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfEditMessages", in: context)
        let messageToSaveOnQueue = QueueOfEditMessages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.content    = editMessage.content
        messageToSaveOnQueue.repliedTo  = editMessage.repliedTo as NSNumber?
        messageToSaveOnQueue.subjectId  = editMessage.subjectId as NSNumber?
        messageToSaveOnQueue.typeCode   = editMessage.typeCode
        messageToSaveOnQueue.uniqueId   = editMessage.uniqueId
        
        if let metaData2 = editMessage.metaData {
            NSObject.convertJSONtoTransformable(dataToStore: metaData2) { (data) in
                messageToSaveOnQueue.metaData = data
            }
        }
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfEditMessages -create a new object-")
    }
    
    func saveForwardMessageToWaitQueue(forwardMessage: QueueOfWaitForwardMessagesModel) {
        let theWaitQueueEntity = NSEntityDescription.entity(forEntityName: "QueueOfForwardMessages", in: context)
        let messageToSaveOnQueue = QueueOfForwardMessages(entity: theWaitQueueEntity!, insertInto: context)
        messageToSaveOnQueue.messageIds = forwardMessage.messageIds as [NSNumber]?
        messageToSaveOnQueue.repliedTo  = forwardMessage.repliedTo as NSNumber?
        messageToSaveOnQueue.subjectId  = forwardMessage.subjectId as NSNumber?
        messageToSaveOnQueue.typeCode   = forwardMessage.typeCode
        messageToSaveOnQueue.uniqueId   = forwardMessage.uniqueId
        
        if let metaData2 = forwardMessage.metaData {
            NSObject.convertJSONtoTransformable(dataToStore: metaData2) { (data) in
                messageToSaveOnQueue.metaData = data
            }
        }
        
        // save function that will try to save changes that made on the Cache
        saveContext(subject: "Create QueueOfForwardMessages -create a new object-")
    }
    
    
    
    
    func retrieveWaitTextMessages(threadId: Int) -> [QueueOfWaitTextMessagesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfTextMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfTextMessages] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitTextMessagesModel]()
                    for item in result {
                        messageArray.append(item.convertQueueOfTextMessagesToQueueOfWaitTextMessagesModelObject())
                    }
                    return messageArray
                    
                }
//                else {
//                    return nil
//                }
            }
//            else {
//                return nil
//            }
        } catch {
            fatalError("Error on fetching list of QueueOfTextMessages")
        }
        return nil
    }
    
    func retrieveWaitFileMessages(threadId: Int) -> [QueueOfWaitFileMessagesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfFileMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfFileMessages] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitFileMessagesModel]()
                    for item in result {
                        messageArray.append(item.convertQueueOfFileMessagesToQueueOfWaitFileMessagesModelObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfFileMessages")
        }
        return nil
    }
    
    func retrieveWaitUploadImages(threadId: Int) -> [QueueOfWaitUploadImagesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfImages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfUploadImages] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitUploadImagesModel]()
                    for item in result {
                        messageArray.append(item.convertQueueOfUploadImagesToQueueOfWaitUploadImagesModelObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfFileMessages")
        }
        return nil
    }
    
    func retrieveWaitUploadFiles(threadId: Int) -> [QueueOfWaitUploadFilesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfUploadFiles")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfUploadFiles] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitUploadFilesModel]()
                    for item in result {
                        messageArray.append(item.convertQueueOfUploadFilesToQueueOfWaitUploadFilesModelObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfFileMessages")
        }
        return nil
    }
    
    func retrieveWaitEditMessages(threadId: Int) -> [QueueOfWaitEditMessagesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfEditMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfEditMessages] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitEditMessagesModel]()
                    for item in result {
                        messageArray.append(item.convertQueueOfEditMessagesToQueueOfWaitEditMessagesModelObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfEditMessages")
        }
        return nil
    }
    
    func retrieveWaitForwardMessages(threadId: Int) -> [QueueOfWaitForwardMessagesModel]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfForwardMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %i", threadId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfForwardMessages] {
                if (result.count > 0) {
                    
                    var messageArray = [QueueOfWaitForwardMessagesModel]()
                    for item in result {
                        messageArray.append(item.convertQueueOfForwardMessagesToQueueOfWaitForwardMessagesModelObject())
                    }
                    return messageArray
                    
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfForwardMessages")
        }
        return nil
    }
    
    
    
    
    func deleteWaitTextMessage(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfTextMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfTextMessages] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfTextMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfTextMessages with uniqueId")
        }
    }
    
    func deleteWaitFileMessage(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfFileMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfFileMessages] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfFileMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfFileMessages with uniqueId")
        }
    }
    
    func deleteWaitUploadImages(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfUploadImages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfUploadImages] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfUploadImages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfUploadImages with uniqueId")
        }
    }
    
    func deleteWaitUploadFiles(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfUploadFiles")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfUploadFiles] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfUploadFiles object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfUploadFiles with uniqueId")
        }
    }
    
    func deleteWaitEditMessage(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfEditMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfEditMessages] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfEditMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfEditMessages with uniqueId")
        }
    }
    
    func deleteWaitForwardMessage(uniqueId: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QueueOfForwardMessages")
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        fetchRequest.predicate = threadPredicate
        
        do {
            if let result = try context.fetch(fetchRequest) as? [QueueOfForwardMessages] {
                if (result.count > 0) {
                    deleteAndSave(object: result.first!, withMessage: "QueueOfForwardMessages object Deleted from cache")
                }
            }
        } catch {
            fatalError("Error on fetching list of QueueOfForwardMessages with uniqueId")
        }
    }
    
    
}










