//
//  CasheFactory.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/2/21.
//

import Foundation
public class CacheFactory {
    
    public enum ReadCacheType {
        case GET_CASHED_CONTACTS(_ req:ContactsRequest?)
        case GET_THREADS(_ req:ThreadsRequest)
        case GET_BLOCKED_USERS
        case GET_THREAD_PARTICIPANTS(_ req:ThreadParticipantsRequest)
        case CUREENT_USER_ROLES(_ threadId:Int)
        case USER_INFO
        case ALL_UNREAD_COUNT
        case MENTIONS
        case GET_HISTORY(_ req: NewGetHistoryRequest)
        case GET_TEXT_NOT_SENT_REQUESTS(_ threadId:Int)
        case EDIT_MESSAGE_REQUESTS(_ threadId:Int)
        case FORWARD_MESSAGE_REQUESTS(_ threadId:Int)
        case FILE_MESSAGE_REQUESTS(_ threadId:Int)
        case UPLOAD_FILE_REQUESTS(_ threadId:Int)
        case UPLOAD_IMAGE_REQUESTS(_ threadId:Int)
        case THREAD_ADMINS(_ threadId:Int)
        case THREAD_PARTICIPANTS(_ threadId:Int, _ count:Int , _ offset:Int , _ ascending:Bool)
        case PIN_THREADS
        case NEW_THREADS(_ count:Int , _ offset:Int)
        case PHONE_CONTACTS
        case ALL_THREADS
        case GET_ASSISTANTS(_ count:Int, _ offset:Int)
        case GET_BLOCKED_ASSISTANTS(_ count:Int, _ offset:Int)
        case GET_MUTUAL_GROUPS(_ req:MutualGroupsRequest)
    }
    
    public enum WriteCacheType {
        case DELETE_ALL_CACHE_DATA
        case CASHE_CONTACTS(_ contacts:[Contact])
        case THREADS(_ threads:[Conversation])
        case GET_BLOCKED_USERS
        case PARTICIPANTS(_ participants:[Participant]? , _ threadId:Int?)
        case REMOVE_PARTICIPANTS(participants:[Participant]? , threadId:Int?)
        case LEAVE_THREAD(_ conversation:Conversation)
        case CURRENT_USER_ROLES(_ roles:[Roles] , _ threadId:Int?)
        case USER_INFO(_ user:User)
        case PIN_MESSAGE(_ pinMessage:PinUnpinMessage, _ threadId:Int?)
        case UNPIN_MESSAGE(_ unpinMessage:PinUnpinMessage, _ threadId:Int?)
        case CLEAR_ALL_HISTORY(_ threadId:Int)
        case DELETE_MESSAGE(_ threadId:Int , messageId:Int)
        case DELETE_MESSAGES(_ threadId:Int , messageIds:[Int])
        case SEND_TXET_MESSAGE_QUEUE(_ req:NewSendTextMessageRequest)
        case DELETE_SEND_TXET_MESSAGE_QUEUE(_ uniqueId:String)
        case MESSAGE(_ message:Message)
        case EDIT_MESSAGE_QUEUE(_ req : NewEditMessageRequest)
        case DELETE_EDIT_MESSAGE_QUEUE(_ message:Message)
        case FORWARD_MESSAGE_QUEUE(_:NewForwardMessageRequest)
        case DELETE_FORWARD_MESSAGE_QUEUE(_ uniqueId:String)
        case DELETE_FILE_MESSAGE_QUEUE(_ uniqueId:String)
        case SEND_FILE_MESSAGE_QUEUE(_ req:NewUploadFileRequest, _ textMessage: NewSendTextMessageRequest)
        case UPLOAD_FILE_QUEUE(_ req:NewUploadFileRequest)
        case UPLOAD_IMAGE_QUEUE(_ req:NewUploadImageRequest)
        case DELETE_UPLOAD_IMAGE_QUEUE(_ uniqueId:String)
        case DELETE_UPLOAD_FILE_QUEUE(_ uniqueId:String)
        case DELETE_ALL_USER
        case DELETE_CONTACTS(_ contactIds:[Int])
        case DELETE_THREADS(_ threadIds:[Int])
        case DELETE_ALL_CONTACTS
        case DELETE_ALL_THREADS
        case DELETE_ALL_MESSAGE
        case SYNCED_CONTACTS
        case DELETE_WAIT_TEXT_MESSAGE(_ uniqueId:String)
        case DELETE_EDIT_TEXT_MESSAGE(_ uniqueId:String)
        case DELETE_FORWARD_MESSAGE(_ uniqueId:String)
        case DELETE_WAIT_FILE_MESSAGE(_ uniqueId:String)
        case SET_THREAD_UNREAD_COUNT(_ threadId:Int, _ unreadCount:Int )
        case INSERT_OR_UPDATE_ASSISTANTS(_ assistants:[Assistant])
        case DELETE_ASSISTANTS(_ assistant:[Assistant])
        case MUTUAL_GROUPS(_ threads:[Conversation] , _ req:MutualGroupsRequest)
        case MUTE_UNMUTE_THREAD(_ threadId:Int)
    }
    
    public class func get(useCache: Bool = false , cacheType: ReadCacheType , completion: ((ChatResponse)->())? = nil){
        if Chat.sharedInstance.config?.enableCache == true && useCache == true{
            switch cacheType {
            case .GET_CASHED_CONTACTS(_ :let req):
                let contacts = CMContact.getContacts(req: req)
                completion?(.init( cacheResponse: contacts))
                break
            case .GET_BLOCKED_USERS:
                //completion?(.init(result: nil, cacheResponse: CMBlocked.crud.getAll().map{$0.convertCMObjectToObject()}, error: nil))
                break
            case .GET_THREADS(_ : let req ):
                let threads = CMConversation.getThreads(req: req)
                completion?(.init(cacheResponse: threads))
                break
            case .GET_THREAD_PARTICIPANTS(_ : let req):
                let predicate:NSPredicate = req.admin ? .init(format: "threadId == %i AND admin == %@" , req.threadId , NSNumber(value:true)) : .init(format:"threadId == %i" , req.threadId)
                let cmParticipants = CMParticipant.crud.fetchWithOffset(count: req.count, offset: req.offset, predicate: predicate)
                let paricipants = cmParticipants.map{$0.getCodable()}
                completion?(.init(cacheResponse: paricipants))
                break
            case .CUREENT_USER_ROLES(_ : let threadId):
                let roles = CMCurrentUserRoles.crud.fetchWith(NSPredicate(format: "threadId == %i" , threadId))
                completion?(.init(cacheResponse: roles?.first?.getCodable()))
                break
            case .USER_INFO:
                let user = CMUser.crud.getAll().first?.getCodable()
                completion?(.init(cacheResponse: user))
                break
            case .ALL_UNREAD_COUNT:
                let allUnreadCount = CMConversation.crud.getAll().compactMap{ $0.unreadCount as? Int ?? 0 }.reduce(0, +)
                completion?(.init(cacheResponse: allUnreadCount))
                break
            case .MENTIONS:
                let mentions = CMMessage.crud.fetchWith(NSPredicate(format: "mentioned == %@", NSNumber(value: true)))?.map{$0.getCodable()}
                completion?(.init(cacheResponse: mentions))
                break
            case .GET_HISTORY(_ : let req):
                let fetchRequest = CMMessage.fetchRequestWithGetHistoryRequest(req: req)
                let messages = CMMessage.crud.fetchWith(fetchRequest)?.map{$0.getCodable()}
                completion?(.init(cacheResponse: messages))
                break
            case .GET_TEXT_NOT_SENT_REQUESTS(_: let threadId):
                let requests = QueueOfTextMessages.crud.fetchWith(NSPredicate(format: "threadId == %i" , threadId))?.compactMap{$0.getCodable()}
                completion?(.init(cacheResponse: requests))
                break
            case .EDIT_MESSAGE_REQUESTS(_ : let threadId):
                let requests = QueueOfEditMessages.crud.fetchWith(NSPredicate(format: "threadId == %i" , threadId))?.compactMap{$0.getCodable()}
                completion?(.init(cacheResponse: requests))
                break
            case .FORWARD_MESSAGE_REQUESTS(_: let threadId):
                let requests = QueueOfForwardMessages.crud.fetchWith(NSPredicate(format: "threadId == %i" , threadId))?.compactMap{$0.getCodable()}
                completion?(.init(cacheResponse: requests))
                break
            case .FILE_MESSAGE_REQUESTS(_: let threadId):
                let requests = QueueOfFileMessages.crud.fetchWith(NSPredicate(format: "threadId == %i" , threadId))?.compactMap{$0.getCodable()}
                completion?(.init(cacheResponse: requests))
                break
            case .UPLOAD_FILE_REQUESTS(_: let threadId):
                let requests = QueueOfUploadFiles.crud.fetchWith(NSPredicate(format: "uniqueId == %i" , threadId))?.compactMap{$0.getCodable()}
                completion?(.init(cacheResponse: requests))
                break
            case .UPLOAD_IMAGE_REQUESTS(_: let threadId):
                let requests = QueueOfUploadImages.crud.fetchWith(NSPredicate(format: "uniqueId == %i" , threadId))?.compactMap{$0.getCodable()}
                completion?(.init(cacheResponse: requests))
                break
            case .THREAD_ADMINS(_: let threadId):
                let admins = CMParticipant.crud.fetchWith(NSPredicate(format: "threadId == %i", threadId))?.filter{$0.roles != nil}
                completion?(.init(cacheResponse:admins))
                break
            case .THREAD_PARTICIPANTS(_: let threadId, _:let count , _:let offset , _:let ascending):
                let nameSort        = NSSortDescriptor(key: "contactName", ascending: ascending)
                let lastNameSort    = NSSortDescriptor(key: "lastName", ascending: ascending)
                let firstNameSort   = NSSortDescriptor(key: "firstName", ascending: ascending)
                let sorts = [nameSort , lastNameSort, firstNameSort]
                let participants = CMParticipant.crud.fetchWithOffset(count: count, offset: offset, predicate: NSPredicate(format: "threadId == %i", threadId) , sortDescriptor: sorts)
                completion?(.init(cacheResponse:participants))
                break
            case .PIN_THREADS:
                let pinThredas = CMConversation.crud.fetchWith(NSPredicate(format:"pin == %@", NSNumber(value: true)))
                completion?(.init(cacheResponse:pinThredas))
                break
            case .NEW_THREADS(_:let count , _:let offset):
                let threads = CMConversation.crud.fetchWithOffset(count: count, offset: offset, predicate: NSPredicate(format: "unreadCount > %i", 0))
                completion?(.init(cacheResponse:threads))
                break
            case .PHONE_CONTACTS:
                let phoneContacts = PhoneContact.crud.getAll()
                completion?(.init(cacheResponse:phoneContacts))
                break
            case .ALL_THREADS:
                let threads = CMConversation.crud.getAll()
                completion?(.init(cacheResponse:threads))
                break
            case .GET_ASSISTANTS(_ :let count, _ :let offset):
                let assistants = CMAssistant.crud.fetchWithOffset(count: count, offset: offset, predicate: nil)
                completion?(.init(cacheResponse:assistants.map{$0.getCodable()}))
                break
            case .GET_BLOCKED_ASSISTANTS(_ :let count, _ :let offset):
                let assistants = CMAssistant.crud.fetchWithOffset(count: count, offset: offset, predicate: NSPredicate(format: "block == %@",NSNumber(value: true)))
                completion?(.init(cacheResponse:assistants.map{$0.getCodable()}))
                break
            case .GET_MUTUAL_GROUPS(_ :let req):
                let conversations = CMMutualGroup.getMutualGroups(req)
                completion?(.init(cacheResponse:conversations))
                break
            }
        }
    }
    
    public class func write(cacheType: WriteCacheType){
        if Chat.sharedInstance.config?.enableCache == true{
            switch cacheType {
            case .CASHE_CONTACTS(contacts: let contacts):
                CMContact.insertOrUpdate(contacts: contacts)
                break
            case .GET_BLOCKED_USERS:
                break
            case .THREADS(_ : let threads):
                CMConversation.insertOrUpdate(conversations: threads)
                break
            case .PARTICIPANTS(_ : let participants , _ : let threadId):
                CMParticipant.insertOrUpdateParicipants(participants: participants ,fromMainMethod: true, threadId: threadId)
                break
            case .REMOVE_PARTICIPANTS(_: let participants, _: let threadId):
                CMParticipant.deleteParticipants(participants: participants , threadId: threadId)
                break
            case .LEAVE_THREAD(_ : let conversation):
                if let threadId = conversation.id{
                    CMParticipant.crud.deleteWith(predicate: NSPredicate(format: "threadId == %i" , threadId))
                    CMConversation.crud.deleteWith(predicate: NSPredicate(format: "id == %i" , threadId))
                }
                break
                
            case .CURRENT_USER_ROLES(_ :let roles, _ :let threadId):
                if let threadId = threadId{
                    CMCurrentUserRoles.insertOrUpdate(roles: roles, threadId: threadId)
                }
                break
            case .USER_INFO(_ : let user):
                CMUser.insertOrUpdate(user: user, resultEntity: nil)
                break
            case .PIN_MESSAGE(_ : let pinMessage , _: let threadId):
                CMPinMessage.pinMessage(pinMessage: pinMessage , threadId: threadId)
                break
            case .UNPIN_MESSAGE(_ : let unpinMessage, _: let threadId):
                CMPinMessage.unpinMessage(pinMessage: unpinMessage , threadId: threadId)
                break
            case .CLEAR_ALL_HISTORY(_: let threadId):
                CMMessage.crud.deleteWith(predicate: NSPredicate(format:"threadId == %i" , threadId))
                break
            case .DELETE_MESSAGE(_ :let threadId , _ :let messageId):
                CMMessage.crud.deleteWith(predicate: NSPredicate(format:"threadId == %i AND id == %i" , threadId , messageId))
                break
            case .DELETE_MESSAGES(_ :let threadId , _ :let messageIds):
                CMMessage.crud.fetchWith(NSPredicate(format:"threadId == %i AND id IN %@" , threadId , messageIds))?.forEach({ entity in
                    CMMessage.crud.delete(entity: entity)
                })
                break
            case .SEND_TXET_MESSAGE_QUEUE(_ :let req):
                QueueOfTextMessages.insert(request: req)
                break
            case .DELETE_SEND_TXET_MESSAGE_QUEUE(_ :let uniqueId):
                QueueOfTextMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
                break
            case .MESSAGE(_ :let message):
                CMMessage.insertOrUpdate(message: message, threadId: message.threadId)
                break
            case .EDIT_MESSAGE_QUEUE(_ :let req):
                QueueOfEditMessages.insert(request: req)
                break
            case .DELETE_EDIT_MESSAGE_QUEUE(_ : let message):
                guard let messageId = message.id ,  let threadId = message.conversation?.id else{return}
                QueueOfEditMessages.crud.deleteWith(predicate: NSPredicate(format: "messageId == %i AND threadId == %i", messageId , threadId))
                break
            case .FORWARD_MESSAGE_QUEUE(_ : let req):
                QueueOfForwardMessages.insert(request: req)
                break
            case .DELETE_FORWARD_MESSAGE_QUEUE(_ : let uniqueId):
                QueueOfForwardMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
                break
            case .SEND_FILE_MESSAGE_QUEUE(_ : let req, _ : let textMessage):
                QueueOfFileMessages.insert(request: req, textMessage: textMessage)
                break
            case .DELETE_FILE_MESSAGE_QUEUE(_ : let uniqueId):
                QueueOfFileMessages.crud.deleteWith(predicate: NSPredicate(format:  "uniqueId == %@", uniqueId))
                break
            case .UPLOAD_FILE_QUEUE(_ : let req):
                QueueOfUploadFiles.insert(request: req)
                break
            case .UPLOAD_IMAGE_QUEUE(_ : let req):
                QueueOfUploadImages.insert(request: req)
                break
            case .DELETE_UPLOAD_IMAGE_QUEUE(_ : let uniqueId):
                QueueOfUploadImages.crud.deleteWith(predicate: NSPredicate(format:  "uniqueId == %@", uniqueId))
                break
            case .DELETE_UPLOAD_FILE_QUEUE(_ : let uniqueId):
                QueueOfUploadFiles.crud.deleteWith(predicate: NSPredicate(format:  "uniqueId == %@", uniqueId))
                break
            case .DELETE_ALL_USER:
                CMUser.crud.deleteAll()
                break
            case .DELETE_CONTACTS(_ :let contactIds):
                CMContact.crud.deleteWith(predicate: NSPredicate(format: "id IN %@", contactIds))
                break
            case .DELETE_THREADS(_:let threadIds):
                CMConversation.crud.deleteWith(predicate: NSPredicate(format: "id IN %@", threadIds))
                break
            case .DELETE_ALL_CONTACTS:
                CMContact.crud.deleteAll()
                break
            case .DELETE_ALL_THREADS:
                CMConversation.crud.deleteAll()
                break
            case .DELETE_ALL_MESSAGE:
                CMMessage.crud.deleteAll()
                break
            case .DELETE_ALL_CACHE_DATA:
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
                QueueOfUploadImages.crud.deleteAll()
                QueueOfUploadFiles.crud.deleteAll()
                QueueOfEditMessages.crud.deleteAll()
                QueueOfForwardMessages.crud.deleteAll()
                CMAssistant.crud.deleteAll()
                CacheFileManager.sharedInstance.deleteAllFiles()
                CacheFileManager.sharedInstance.deleteAllImages()
                break
            case .SYNCED_CONTACTS:
                CMUser.crud.getAll().forEach { user in
                    user.contactSynced = NSNumber(value: true)
                }
                break
            case .DELETE_WAIT_TEXT_MESSAGE(_ : let uniqueId):
                QueueOfTextMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
                break
            case .DELETE_EDIT_TEXT_MESSAGE(_ : let uniqueId):
                QueueOfEditMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
                break
            case .DELETE_FORWARD_MESSAGE(_ : let uniqueId):
                QueueOfForwardMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
                break
            case .DELETE_WAIT_FILE_MESSAGE(_ : let uniqueId):
                QueueOfFileMessages.crud.deleteWith(predicate: NSPredicate(format: "uniqueId == %@", uniqueId))
                break
            case .SET_THREAD_UNREAD_COUNT(_ : let threadId, _ : let unreadCount):
                if let conversation = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId){
                    conversation.unreadCount = NSNumber(value: (unreadCount))
                }
                break
            case .INSERT_OR_UPDATE_ASSISTANTS(_ : let assistants):
                CMAssistant.insertOrUpdate(assistants:assistants)
                break
            case .DELETE_ASSISTANTS(_ : let assistants):
                assistants.forEach { assistant in
                    CMAssistant.crud.deleteWith(predicate: NSPredicate(format: "inviteeId == %i", assistant.participant?.id ?? -1))
                }
                break
            case .MUTUAL_GROUPS(_ : let conversations , _ : let req ):
                CMMutualGroup.insertOrUpdate(conversations: conversations, req: req)
                break
            case .MUTE_UNMUTE_THREAD(_ : let threadId):
                if let conversation = CMConversation.crud.find(keyWithFromat: "id == %i", value: threadId){
                    let isMute = !( (conversation.mute as? Bool) ?? false)
                    conversation.mute = NSNumber(booleanLiteral: isMute)
                }
                break
            }
        }
    }
    class func save(){
        PSM.shared.save()
    }
}
