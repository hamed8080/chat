//
//  RetrieveDataFromCache.swift
//  FanapPodChatSDK
//
//  Created by Mahyar Zhiani on 3/18/1398 AP.
//  Copyright © 1398 Mahyar Zhiani. All rights reserved.
//

import Foundation
import CoreData


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
                                                              errorCode: 0,
                                                              threadId: nil)
                
                //                let getMessageModelResponse = GetHistoryModel(messageContent: messageArr,
                //                                                              contentCount: messageArr.count,
                //                                                              count: count,
                //                                                              offset: offset,
                //                                                              hasError: false,
                //                                                              errorMessage: "",
                //                                                              errorCode: 0)
                
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


