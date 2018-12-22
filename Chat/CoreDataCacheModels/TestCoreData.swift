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



// MARK: - Functions that will save data on COreData Cache

extension Cache {
    
    // this function will save the UserInfo
    public func createUserInfoObject(user: User) {
        // check if there is any information about UserInfo in the cache
        // if it has some data, it we will update that data,
        // otherwise we will create an object and save data on cache
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMUser")
        do {
            if let result = try context.fetch(fetchRequest) as? [CMUser] {
                if (result.count > 0) {
                    result.first!.cellphoneNumber   = user.cellphoneNumber
                    result.first!.email             = user.email
                    result.first!.id                = NSNumber(value: user.id ?? 0)
                    result.first!.image             = user.image
                    result.first!.lastSeen          = NSNumber(value: user.lastSeen ?? 0)
                    result.first!.name              = user.name
                    result.first!.receiveEnable     = NSNumber(value: user.receiveEnable ?? true)
                    result.first!.sendEnable        = NSNumber(value: user.sendEnable ?? true)
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
                }
                // save function that will try to save changes that made on the Cache
                saveContext(subject: "Update UserInfo")
            }
        } catch {
            fatalError("Error on fetching list of Conversations")
        }
    }
    
    
    // this function will save threads that comes from server
    public func saveThreadObjects(threads: [Conversation]) {
        // check if there is any information about Conversations that are in the cache,
        // which are has beed there, it we will update that data,
        // otherwise we will create an object and save data on cache
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        do {
            if let result = try context.fetch(fetchRequest) as? [Conversation] {
                for itemInCache in result {
                    for item in threads {
                        if (itemInCache.id == item.id) {
                            // the conversation object that we are going to create, is already exist in the Cache
                            // so we will delete them first, then we will create it again
                        }
                    }
                }
                
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
                    
                    
                    /*
                     now have to create these three objects, then save them and save relationsips to this class\
                     conversation.inviter:                        Participant?
                     conversation.lastMessageVO:                  Message?
                     conversation.participants:                   [Participant]?
                     */
                    
                }
                
            }
            saveContext(subject: "Update Conversation")
        } catch {
            fatalError("Error on fetching list of CMConversation")
        }
    }
    
    
    
    
}







// MARK: - Functions that will retrieve data from COreData Cache

extension Cache {
    
    
    // retrieve userInfo data from Cache
    // if it found any data from Cache DB, it will return that,
    // otherwise it will return nil. (means cache has no data on itself)
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
    
    // retrieve userInfo data from Cache
    // if it found any data from Cache DB, it will return that,
    // otherwise it will return nil. (means cache has no data on itself)
    // TODO: - Have to implement search in threads by using 'name' and also 'threadIds' properties!
    public func retrieveThreads(count: Int, offset: Int, ascending: Bool) -> GetThreadsModel? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CMConversation")
        let sortByTime = NSSortDescriptor(key: "time", ascending: ascending)
        fetchRequest.sortDescriptors = [sortByTime]
        do {
            if let result = try context.fetch(fetchRequest) as? [CMConversation] {
                
                var insideCount = 0
                var cmConversationObjectArr = [CMConversation]()
                
                for (index, item) in result.enumerated() {
                    if (index >= offset) && (insideCount < count) {
                        cmConversationObjectArr.append(item)
                        insideCount += 1
                    }
                }
                
                var conversationArr = [Conversation]()
                for item in cmConversationObjectArr {
                    conversationArr.append(item.convertCMConversationToConversationObject())
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
    
    
    
}









