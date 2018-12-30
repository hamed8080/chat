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
                    saveContext(subject: "Update UserInfo")
                    
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
                    saveContext(subject: "Update UserInfo")
                }
            }
        } catch {
            fatalError("Error on fetching list of Conversations")
        }
    }
    
    
    // this function will save (or update) threads that comes from server, into the Cache.
    public func saveThreadObjects(threads: [Conversation]) {
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
                            if (conversationId == item.id) {
                                // the conversation object that we are going to create, is already exist in the Cache
                                // to update information in this object:
                                // we will delete them first, then we will create it again later
                                context.delete(itemInCache)
                                saveContext(subject: "Delete Object: \(itemInCache.convertCMConversationToConversationObject().formatToJSON())")
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
                
                saveContext(subject: "Update Conversation")
            }
        } catch {
            fatalError("Error on fetching list of CMConversation")
        }
    }
    
    
    // this function will save (or update) contacts that comes from server, into the Cache.
    public func saveContactObjects(contacts: [Contact]) {
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
                                context.delete(itemInCache)
                                saveContext(subject: "Delete Object: \(itemInCache.convertCMContactToContactObject().formatToJSON())")
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
                
                saveContext(subject: "Update Contact")
            }
        } catch {
            fatalError("Error on fetching list of CMConversation")
        }
    }
    
    
    // this function will save (or update) contacts that comes from server, in the Cache.
    public func saveThreadParticipantObjects(participants: [Participant]) {
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
                                saveContext(subject: "Delete Object: \(itemInCache.convertCMParticipantToParticipantObject().formatToJSON())")
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
    }
    
    
    // this function will save (or update) messages that comes from server, in the Cache.
    public func saveMessageObjects(messages: [Message]) {
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
                                context.delete(itemInCache)
                                saveContext(subject: "Delete Object: \(itemInCache.convertCMMessageToMessageObject().formatToJSON())")
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
        return nil
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
    public func retrieveThreads(count:      Int,
                                offset:     Int,
                                ascending:  Bool,
                                name:       String?,
                                threadIds:  [Int]?) -> GetThreadsModel? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        
        // use this array to make logical or for threads
        var fetchPredicatArray = [NSPredicate]()
        // put the search statement on the predicate to search throut the Conversations(Threads)
        if let searchStatement = name {
            let searchTitle = NSPredicate(format: "title CONTAINS[cd] %@", searchStatement)
            let searchDescriptions = NSPredicate(format: "descriptions CONTAINS[cd] %@", searchStatement)
            fetchPredicatArray.append(searchTitle)
            fetchPredicatArray.append(searchDescriptions)
        }
        
        // loop through the threadIds Arr that the user seends, and fill the 'fetchPredicatArray' property to predicate
        if let searchThreadId = threadIds {
            for i in searchThreadId {
                let threadIdPredicate = NSPredicate(format: "id == %@", i)
                fetchPredicatArray.append(threadIdPredicate)
            }
        }
        
        let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: fetchPredicatArray)
        fetchRequest.predicate = predicateCompound
        // sort the result by the time
        let sortByTime = NSSortDescriptor(key: "time", ascending: ascending)
        fetchRequest.sortDescriptors = [sortByTime]
        
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                
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
                                                             contentCount:  0,
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
            fatalError("Error on fetching list of Conversations")
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
    public func retrieveContacts(count:             Int,
                                 offset:            Int,
                                 ascending:         Bool,
                                 search:            String?,
                                 firstName:         String?,
                                 lastName:          String?,
                                 cellphoneNumber:   String?,
                                 email:             String?,
                                 uniqueId:          String?,
                                 id:                Int?) -> GetContactsModel? {
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
            theOnlyPredicate = NSPredicate(format: "id == %@", theId)
            fetchRequest.predicate = theOnlyPredicate
        } else if let theUniqueId = uniqueId {
            theOnlyPredicate = NSPredicate(format: "uniqueId == %@", theUniqueId)
            fetchRequest.predicate = theOnlyPredicate
        } else {
            
            var andPredicateArr = [NSPredicate]()
            if let theCellphoneNumber = cellphoneNumber {
                let theCellphoneNumberPredicate = NSPredicate(format: "cellphoneNumber CONTAINS[cd] %@", theCellphoneNumber)
                andPredicateArr.append(theCellphoneNumberPredicate)
            }
            if let theFirstName = firstName {
                let theFirstNamePredicate = NSPredicate(format: "firstName CONTAINS[cd] %@", theFirstName)
                andPredicateArr.append(theFirstNamePredicate)
            }
            if let theLastName = lastName {
                let theLastNamePredicate = NSPredicate(format: "lastName CONTAINS[cd] %@", theLastName)
                andPredicateArr.append(theLastNamePredicate)
            }
            if let theEmail = email {
                let theEmailPredicate = NSPredicate(format: "email CONTAINS[cd] %@", theEmail)
                andPredicateArr.append(theEmailPredicate)
            }
            let andPredicateCompound = NSCompoundPredicate(type: .and, subpredicates: andPredicateArr)
            
            var orPredicatArray = [NSPredicate]()
            orPredicatArray.append(andPredicateCompound)
            
            if let searchStatement = search {
                let theSearchPredicate = NSPredicate(format: "cellphoneNumber CONTAINS[cd] %@ OR email CONTAINS[cd] %@ OR firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", searchStatement, searchStatement, searchStatement, searchStatement)
                orPredicatArray.append(theSearchPredicate)
//                let searchCellphoneNumber = NSPredicate(format: "cellphoneNumber CONTAINS[cd] %@", searchStatement)
//                let searchEmail = NSPredicate(format: "email CONTAINS[cd] %@", searchStatement)
//                let searchFirstName = NSPredicate(format: "firstName CONTAINS[cd] %@", searchStatement)
//                let searchLastName = NSPredicate(format: "lastName CONTAINS[cd] %@", searchStatement)
//                fetchPredicatArray.append(searchCellphoneNumber)
//                fetchPredicatArray.append(searchEmail)
//                fetchPredicatArray.append(searchFirstName)
//                fetchPredicatArray.append(searchLastName)
            }
            
            let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: orPredicatArray)
            fetchRequest.predicate = predicateCompound
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
                
                let getContactModelResponse = GetContactsModel(contactsObject: contactsArr,
                                                               contentCount: 0,
                                                               count: count,
                                                               offset: offset,
                                                               hasError: false,
                                                               errorMessage: "",
                                                               errorCode: 0)
                
                return getContactModelResponse
                
            } else {
                return nil
            }
        } catch {
            fatalError("Error on fetching list of Conversations")
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
    public func retrieveThreadParticipants(count:       Int,
                                           offset:      Int,
                                           ascending:   Bool) -> GetThreadParticipantsModel? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMParticipant")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMParticipant] {
                
                var insideCount = 0
                var cmParticipantObjectArr = [CMParticipant]()
                
                for (index, item) in result.enumerated() {
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
        } catch {
            fatalError("Error on fetching list of Conversations")
        }
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
                                       offset:          Int,
                                       ascending:       Bool,
                                       threadId:        Int,
                                       firstMessageId:  Int?,
                                       lastMessageId:   Int?,
                                       query:           String?) -> GetHistoryModel? {
        /*
         first we have to make AND of these 2 properties: 'firstMessageId' AND 'lastMessageId'.
         then make them OR with 'query' property.
         ( (firstMessageId AND lastMessageId) OR query )
         after that, we will order them by the time, then based on the 'count' and 'offset' properties,
         we create the output model and return it.
         after all we only have to show messages that blongs to the 'threadId' property,
         so we AND the result of last operation with 'threadId' property.
         */
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMMessage")
        
        // sort the result by the time
        let sortByTime = NSSortDescriptor(key: "time", ascending: ascending)
        fetchRequest.sortDescriptors = [sortByTime]
        
        // AND predicate for 'firstMessageId' AND 'lastMessageId'
        var andPredicateArr = [NSPredicate]()
        if let first = firstMessageId {
            let firstPredicate = NSPredicate(format: "id >= %@", first)
            andPredicateArr.append(firstPredicate)
        }
        if let last = lastMessageId {
            let lastPredicate = NSPredicate(format: "id <= %@", last)
            andPredicateArr.append(lastPredicate)
        }
        let firstANDlastCompound = NSCompoundPredicate(type: .and, subpredicates: andPredicateArr)
        
        // use this array to make logical OR between the result of the 'firstANDlastCompound' and 'query'
        var searchPredicatArray = [NSPredicate]()
        searchPredicatArray.append(firstANDlastCompound)
        // put the search statement on the predicate to search through the Messages
        if let searchStatement = query {
            let searchMessages = NSPredicate(format: "message CONTAINS[cd] %@", searchStatement)
            searchPredicatArray.append(searchMessages)
        }
        
        let queryORfirstlastCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: searchPredicatArray)
        
        // this predicate used to get messages that are in the specific thread using 'threadId' property
        let threadPredicate = NSPredicate(format: "threadId == %@", threadId)
        let finalPredicate: [NSPredicate] = [threadPredicate, queryORfirstlastCompound]
        let predicateCompound = NSCompoundPredicate(type: .and, subpredicates: finalPredicate)
        
        fetchRequest.predicate = predicateCompound
        
        
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
                                                              contentCount: 0,
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
            fatalError("Error on fetching list of Conversations")
        }
    }
    
    
    
    
}










