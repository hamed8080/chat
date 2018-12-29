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
        // which are has beed there, it we will update that data,
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
    public func saveContactsObjects(contacts: [Contact]) {
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
    public func saveThreadParticipantsObjects(participants: [Participant]) {
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
    public func retrieveThreads(count: Int, offset: Int, ascending: Bool, name: String?, threadIds: [Int]?) -> GetThreadsModel? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        
        // use this array to make logical or for threads
        var fetchPredicatArray = [NSPredicate]()
        // put the search statement on the predicate to search throut the Conversations(Threads)
        if let searchStatement = name {
            let searchTitle = NSPredicate(format: "title == %@", searchStatement)
            let searchDescriptions = NSPredicate(format: "descriptions == %@", searchStatement)
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
                        print("item added to the Array")
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
    public func retrieveContacts(count: Int, offset: Int, ascending: Bool, name: String?) -> GetContactsModel? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMContact")
        
        var fetchPredicatArray = [NSPredicate]()
        if let searchStatement = name {
            let searchCellphoneNumber = NSPredicate(format: "cellphoneNumber == %@", searchStatement)
            let searchEmail = NSPredicate(format: "email == %@", searchStatement)
            let searchFirstName = NSPredicate(format: "firstName == %@", searchStatement)
            let searchLastName = NSPredicate(format: "lastName == %@", searchStatement)
            
            fetchPredicatArray.append(searchCellphoneNumber)
            fetchPredicatArray.append(searchEmail)
            fetchPredicatArray.append(searchFirstName)
            fetchPredicatArray.append(searchLastName)
        }
        
        let predicateCompound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: fetchPredicatArray)
        fetchRequest.predicate = predicateCompound
        
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
    // TODO: - Have to implement search in contacts by using 'name' property!
    public func retrieveThreadParticipants(count: Int, offset: Int, ascending: Bool) -> GetThreadParticipantsModel? {
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
    
    
}










