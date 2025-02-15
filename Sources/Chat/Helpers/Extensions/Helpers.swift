//
//  Helpers.swift
//  Chat
//
//  Created by Hamed Hosseini on 1/2/25.
//

import ChatCore
import ChatModels
import Contacts
#if canImport(UIKit)
import UIKit
#endif

internal extension ChatResponse where T == Message {
    func deleteTuple(_ userId: Int?) -> (threadId: Int, messageId: Int, userId: Int)? {
        guard let threadId = subjectId,
              let messageId = result?.id,
              let userId = userId
        else { return nil }
        return (threadId, messageId, userId)
    }
}

internal func imageSize(data: Data) -> CGSize {
    var size = CGSize(width: 0, height: 0)
#if canImport(UIKit)
    let image = UIImage(data: data) ?? UIImage()
    size = image.size
#endif
    return size
}

internal func mapImageToRequest(_ data: Data, _ request: LocationMessageRequest) -> (reverseReq: MapReverseRequest, uploadImageReq: UploadImageRequest, sendTextReq: SendTextMessageRequest) {
    let mapSize = imageSize(data: data)
    /// Convert and set uniqueId request
    let imageRequest = request.imageRequest(data: data, wC: Int(mapSize.width), hC: Int(mapSize.height))
    let textMessageReq = request.textMessageRequest
    let req = MapReverseRequest(lat: request.mapCenter.lat, lng: request.mapCenter.lng)
    return (req, imageRequest, textMessageReq)
}

internal func toConversation(request: SendTextMessageRequest) -> Conversation {
    let lastMessageVO = Message(threadId: request.threadId, message: request.textMessage, uniqueId: request.uniqueId)
    return Conversation(id: request.threadId, lastMessage: lastMessageVO.message, lastMessageVO: lastMessageVO.toLastMessageVO)
}

internal func lastMessageToConversation(thread: Conversation) -> Conversation {
    let lastMessageVO = Message(threadId: thread.id, message: thread.lastMessage)
    return Conversation(id: lastMessageVO.threadId, lastMessage: lastMessageVO.message, lastMessageVO: lastMessageVO.toLastMessageVO)
}

internal extension Message {
    func messageToConversation() -> Conversation {
        Conversation(id: threadId, lastMessage: message, lastMessageVO: toLastMessageVO)
    }
}

internal extension FileMetaData {
    func toMapMetaData(coordinate: Coordinate) -> FileMetaData {
        var metaData = self
        let mapLink = "\(Routes.baseMapLink.rawValue)\(coordinate.lat),\(coordinate.lng)"
        metaData.latitude = coordinate.lat
        metaData.longitude = coordinate.lng
        metaData.reverse = reverse.string
        metaData.mapLink = mapLink        
        return metaData
    }
}

extension Array<CacheQueueOfTextMessagesManager.Entity> {
    func toEvent(_ request: GetHistoryRequest, _ typeCode: String?) -> ChatEventType {        
        let requests = map(\.codable.request)
        let response = ChatResponse(uniqueId: request.uniqueId, result: requests, cache: true, typeCode: typeCode)
        return .message(.queueTextMessages(response))
    }
}

extension Array<CacheQueueOfEditMessagesManager.Entity> {
    func toEvent(_ request: GetHistoryRequest, _ typeCode: String?) -> ChatEventType {
        let requests = map(\.codable.request)
        let response = ChatResponse(uniqueId: request.uniqueId, result: requests, cache: true, typeCode: typeCode)
        return .message(.queueEditMessages(response))
    }
}

extension Array<CacheQueueOfForwardMessagesManager.Entity> {
    func toEvent(_ request: GetHistoryRequest, _ typeCode: String?) -> ChatEventType {
        let requests = map(\.codable.request)
        let response = ChatResponse(uniqueId: request.uniqueId, result: requests, cache: true, typeCode: typeCode)
        return .message(.queueForwardMessages(response))
    }
}

extension Array<CacheQueueOfFileMessagesManager.Entity> {
    func toEvent(_ request: GetHistoryRequest, _ typeCode: String?) -> ChatEventType {
        let requests = map(\.codable.request)
        let response = ChatResponse(uniqueId: request.uniqueId, result: requests, cache: true, typeCode: typeCode)
        return .message(.queueFileMessages(response))
    }
}

extension Array<CacheMessageManager.Entity> {
    func toMentionEvent(_ request: MentionRequest, _ typeCode: String?) -> ChatEventType {
        let messages = map { $0.codable() }
        let hasNext = messages.count >= request.count
        let response = ChatResponse(uniqueId: request.uniqueId, result: messages, hasNext: hasNext, typeCode: typeCode)
        return .message(.messages(response))
    }
}

extension ChatResponse<Message> {
    func onNewMesageTuple(myId: Int?) -> (unreadAction: CacheUnreadCountAction, message: Message)? {
        guard let unreadAction = toUnreadAction(myId: myId),
        let fixedThreadIdMessage = fixedThreadId()
        else { return nil }
        return (unreadAction, fixedThreadIdMessage)
    }
    
    func fixedThreadId() -> Message? {
        if result?.threadId == nil {
            var copiedMessage = result
            let threadId = copiedMessage?.conversation?.id
            copiedMessage?.threadId = subjectId ?? threadId
            return copiedMessage
        }
        return result
    }
    
    func toUnreadAction(myId: Int?) -> CacheUnreadCountAction? {
        guard var copiedMessage = result else { return nil }
        /// If we were sender of the message therfore we have seen all the messages inside the thread.
        let isMe = copiedMessage.participant?.id == myId
        return isMe ? .set(0) : .increase
    }
}


// Typealiases
typealias ReplyPrivatelyResponse = (uploadedRes: UploadResult?,
                                    replyMessage: ReplyPrivatelyRequest,
                                    uniqueId: String)

public extension UploadResult {
    func toMapMetaData(_ coordinate: Coordinate) -> UploadResult {
        let mapMetaData = metaData?.toMapMetaData(coordinate: coordinate)
        var resp = self
        resp.metaData = mapMetaData
        return resp
    }
}


extension ChatResponse where T == Int? {
    init(userInfoRes: ChatResponse<User>) {
        let newRes = ChatResponse(uniqueId: userInfoRes.uniqueId, result: userInfoRes.time, time: userInfoRes.time, typeCode: userInfoRes.typeCode)
        self = newRes
    }
}

extension ChatInternalProtocol {
    func cachedUserRoles(_ request: GeneralSubjectIdRequest) -> ChatResponse<[Roles]> {
        let roles = cache?.userRole?.roles(request.subjectId)
        let typeCode = request.toTypeCode(self)
        return ChatResponse<[Roles]>(uniqueId: request.uniqueId, result: roles, cache: true, typeCode: typeCode)
    }
    
    func deleteDocumentFolders() {
        if let docFoler = cacheFileManager?.documentPath {
            cacheFileManager?.deleteFolder(url: docFoler)
        }

        if let groupFoler = cacheFileManager?.groupFolder {
            cacheFileManager?.deleteFolder(url: groupFoler)
        }
    }
}

extension ChatResponse where T == [UserRole] {
    func fixUserRolesThreadId() -> [UserRole] {
        var userRoles = result ?? []
        for (i, _) in userRoles.enumerated() {
            userRoles[i].threadId = subjectId
        }
        return userRoles
    }
}

extension CacheUserManager.Entity? {
    func toEvent(_ request: UserInfoRequest, _ typeCode: String?) -> ChatEventType {
        let response = ChatResponse<User>(uniqueId: request.uniqueId, result: self?.codable, cache: true, typeCode: typeCode)
        return .user(.user(response))
    }
}

extension Dictionary where Key == String, Value == Int {
    func toCachedUnreadCountEvent(_ request: ThreadsUnreadCountRequest, _ typeCode: String?) -> ChatEventType {
        let response = ChatResponse(uniqueId: request.uniqueId, result: self, cache: true, typeCode: typeCode)
        return .thread(.unreadCount(response))
    }
}

extension Int {
    func toAllCachedUnreadCountEvent(_ request: AllThreadsUnreadCountRequest, _ typeCode: String?) -> ChatEventType {
        let response = ChatResponse(uniqueId: request.uniqueId, result: self, cache: true, typeCode: typeCode)
        return .thread(.allUnreadCount(response))
    }
}

func toCurrentUserRoleErrorEvent(_ request: SafeLeaveThreadRequest, typeCode: String?) -> ChatEventType {
    let chatError = ChatError(message: "Current User have no Permission to Change the ThreadAdmin", code: 6666, hasError: true)
    let response = ChatResponse<Sendable>(uniqueId: request.uniqueId, error: chatError, typeCode: typeCode)
    return .system(.error(response))
}


extension ChatResponse<[Roles]> {
    func safeLeaveRole(_ mapRequests: [String: Any]) -> (roleRequest: RolesRequest?, request: SafeLeaveThreadRequest?) {
        guard let uniqueId = uniqueId, let request = mapRequests[uniqueId] as? SafeLeaveThreadRequest else { return (nil,nil) }
        let isAdmin = result?.contains(.threadAdmin) ?? false || result?.contains(.addRuleToUser) ?? false
        if isAdmin, let roles = result {
            let roleRequest = request.roleRequest(roles: roles)
            return (roleRequest, request)
        }
        return (nil, request)
    }
}

extension Array<CacheMutualGroupManager.Entity> {
    func toCachedMutualGroupEvent(_ request: MutualGroupsRequest, _ typeCode: String?) -> ChatEventType {
        let threads = first?.conversations?.allObjects.compactMap { $0 as? CDConversation }.map { $0.codable() }
        let response = ChatResponse(uniqueId: request.uniqueId, result: threads, hasNext: threads?.count ?? 0 >= request.count, cache: true, typeCode: typeCode)
        return .thread(.mutual(response))
    }
}


extension ChatResponse<Int> {
    func toConversation() -> ChatResponse<Conversation> {
        return ChatResponse<Conversation>(uniqueId: uniqueId,
                                          result: Conversation(id: result ?? subjectId),
                                          error: error,
                                          contentCount: contentCount,
                                          hasNext: hasNext,
                                          cache: cache,
                                          subjectId: subjectId,
                                          time: time,
                                          typeCode: typeCode)
    }
}

extension ChatResponse<LastSeenMessageResponse> {
    func toCacheLastSeenTuple() -> (cacheLastSeenReponse: CacheLastSeenMessageResponse, threadId: Int, unreadCount: Int)? {
        guard
            let threadId = result?.id,
            let unreadCount = result?.unreadCount
        else { return nil }
        let seen = CacheLastSeenMessageResponse(threadId: threadId,
                                  lastSeenMessageId: result?.lastSeenMessageId ?? -1,
                                  lastSeenMessageTime: result?.lastSeenMessageTime,
                                  lastSeenMessageNanos: result?.lastSeenMessageNanos)
        
        return (seen, threadId, unreadCount)
    }
}

extension AsyncMessage {
    
    @ChatGlobalActor
    func pinUnpinTuple() -> (conversationId: Int, pinned: Bool, event: ChatEventType) {
        let response: ChatResponse<Int> = toChatResponse()
        let conversationId = response.result ?? -1
        let conversationResp = response.toConversation()
        let pinned = chatMessage?.type == .pinThread
        let event = ChatEventType.thread(pinned ? .pin(conversationResp) : .unpin(conversationResp))
        return (conversationId, pinned, event)
    }
    
    @ChatGlobalActor
    func muteUnMuteTuple() -> (conversationId: Int, mute: Bool, event: ChatEventType) {
        let response: ChatResponse<Int> = toChatResponse()
        let conversationId = response.result ?? response.subjectId ?? -1
        let mute = chatMessage?.type == .muteThread
        let event = ChatEventType.thread(mute ? .mute(response) : .unmute(response))
        return (conversationId, mute, event)
    }
}

extension Array<CacheAssistantManager.Entity> {
    func toCachedAssistantsEvent(_ request: AssistantsRequest, _ typeCode: String?) -> ChatEventType {
        let assistants = map(\.codable)
        let hasNext = count >= request.count
        let response = ChatResponse<[Assistant]>(uniqueId: request.uniqueId, result: assistants, hasNext: hasNext, cache: true, typeCode: typeCode)
        return .assistant(.assistants(response))
    }
    
    func toCachedBlockedAssistantsEvent(_ request: BlockedAssistantsRequest, _ typeCode: String?) -> ChatEventType {
        let assistants = map(\.codable)
        let hasNext = count >= request.count
        let response = ChatResponse(uniqueId: request.uniqueId, result: assistants, hasNext: hasNext, cache: true, typeCode: typeCode)
        return .assistant(.blockedList(response))
    }
}


@ChatGlobalActor
extension ContactManager {
    var contactKeys: [String] {
        [CNContactGivenNameKey,
         CNContactFamilyNameKey,
         CNContactPhoneNumbersKey,
         CNContactEmailAddressesKey]
    }
}

extension CNContact {
    func toContact() -> Contact {
        var contactModel = Contact()
        contactModel.cellphoneNumber = phoneNumbers.first?.value.stringValue ?? ""
        contactModel.firstName = givenName
        contactModel.lastName = familyName
        contactModel.email = emailAddresses.first?.value as String?
        return contactModel
    }
}

func contactHeaders(token: String, xform: Bool = false) -> [String: String] {
    if xform {
        ["_token_": token, "_token_issuer_": "1", "Content-Type": "application/x-www-form-urlencoded"]
    } else {
        ["_token_": token, "_token_issuer_": "1"]
    }
}

extension RemoveContactsRequest {
    func toURLReq(_ urlString: String, _ token: String, _ typeCode: String?) -> URLRequest {
        let headers = contactHeaders(token: token)
        var request = self
        request.setTypeCode(typeCode: typeCode)
                
        let bodyData = request.parameterData
        var urlReq = URLRequest(url: URL(string: urlString)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        urlReq.method = .post
        return urlReq
    }
}

extension AddContactRequest {
    func toAddReq(_ urlString: String, _ token: String, _ typeCode: String?) -> URLRequest {
        // Change TypeCodeIndex to typeCode string
        let headers = contactHeaders(token: token, xform: true)
        var newRequest = self
        newRequest.setTypeCode(typeCode: typeCode)
        
        let bodyData = newRequest.parameterData
        var urlReq = URLRequest(url: URL(string: urlString)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        urlReq.method = .post
        return urlReq
    }
}


extension Array<AddContactRequest> {
    func toCompnents(url: String) -> URLComponents {
        var urlComp = URLComponents(string: url)!
        urlComp.queryItems = []
        forEach { contact in

            // ****
            // do not use if let to only pass un nil value if you pass un nil value in some property like email value are null so
            // the number of paramter is not equal in all contact and get invalid request like below:
            // [firstname,lastname,email,cellPhoneNumber],[firstname,lastname,cellPhoneNumber]
            // ****
            urlComp.queryItems?.append(URLQueryItem(name: "firstName", value: contact.firstName))
            urlComp.queryItems?.append(URLQueryItem(name: "lastName", value: contact.lastName))
            urlComp.queryItems?.append(URLQueryItem(name: "email", value: contact.email))
            urlComp.queryItems?.append(URLQueryItem(name: "cellphoneNumber", value: contact.cellphoneNumber))
            if let userName = contact.username {
                urlComp.queryItems?.append(URLQueryItem(name: "username", value: userName))
            }
            urlComp.queryItems?.append(URLQueryItem(name: "uniqueId", value: contact.uniqueId))
        }
        return urlComp
    }
    
    func toAddAllReq(url: String, token: String) -> URLRequest? {
        let urlComp = toCompnents(url: url)
        guard let urlString = urlComp.string else { return nil }
        
        let headers = contactHeaders(token: token, xform: true)
        var urlReq = URLRequest(url: URL(string: urlString)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.method = .post
        return urlReq
    }
}

extension Array<CacheContactManager.Entity> {
    func toCachedContactsEvent(_ request: ContactsRequest, _ typeCode: String?) -> ChatEventType {
        let contacts = map(\.codable)
        let hasNext = contacts.count >= request.size
        let response = ChatResponse(uniqueId: request.uniqueId, result: contacts, hasNext: hasNext, cache: true, typeCode: typeCode)
        return .contact(.contacts(response))
    }
}


extension Array<CDContact> {
    func toSyncContactsRequest(newContacts: [Contact]) -> [AddContactRequest]? {
        var contactsToSync: [AddContactRequest] = []
        newContacts.forEach { phoneContact in
            if let findedContactchat = first(where: { $0.cellphoneNumber == phoneContact.cellphoneNumber }) {
                if findedContactchat.isContactChanged(contact: phoneContact) {
                    contactsToSync.append(phoneContact.request)
                }
            } else {
                contactsToSync.append(phoneContact.request)
            }
        }
        var uniqueIds: [String] = []
        contactsToSync.forEach { contact in
            uniqueIds.append(contact.uniqueId)
        }
        if contactsToSync.count <= 0 { return nil }
        return contactsToSync
    }
}

extension ContactManager {
    
    typealias RemovedContactData = (data: Data?, urlResponse: URLResponse?, error: Error?, typeCode: String?, request: RemoveContactsRequest)
    func toRemoveContactRevent(removeData: RemovedContactData) -> (event: ChatEventType, removeResp: RemoveContactResponse?, contactId: Int) {
        let response: ChatResponse<RemoveContactResponse>? = removeData.data?.decode(removeData.urlResponse, removeData.error, typeCode: removeData.typeCode)
        let deletedContacts = [Contact(id: removeData.request.contactId)]
        let chatResponse = ChatResponse(uniqueId: removeData.request.uniqueId, result: deletedContacts, error: response?.error, typeCode: removeData.typeCode)
        let event = ChatEventType.contact(.delete(chatResponse, deleted: response?.result?.deteled ?? false))
        return (event, response?.result, removeData.request.contactId)
    }
}


extension ReactionListRequest {
    func toListResponse(reactions: [Reaction], typeCode: String?) -> ChatResponse<ReactionList> {
        ChatResponse<ReactionList>(uniqueId: uniqueId,
                                   result: .init(messageId: messageId, reactions: reactions),
                                   cache: true,
                                   subjectId: conversationId,
                                   typeCode: typeCode)
    }
}

extension ReactionCountRequest {
    func toCountListResponse(list: [ReactionCountList], typeCode: String?) -> ChatResponse<[ReactionCountList]> {
        ChatResponse<[ReactionCountList]>(uniqueId: uniqueId,
                                          result: list,
                                          cache: true,
                                          subjectId: conversationId,
                                          typeCode: typeCode)
    }
}

extension UserReactionRequest {
    func toCurrentUserReactionResponse(reaction: Reaction, typeCode: String?) -> ChatResponse<CurrentUserReaction> {
        ChatResponse<CurrentUserReaction>(uniqueId: uniqueId,
                                          result: .init(messageId: messageId, reaction: reaction),
                                          cache: true,
                                          subjectId: conversationId,
                                          typeCode: typeCode)
    }
}


extension ReactionCountRequest {
    func toCountResponse(models: [ReactionCountList], typeCode: String?) -> ChatResponse<[ReactionCountList]> {
        ChatResponse(uniqueId: uniqueId,
                     result: models,
                     error: nil,
                     contentCount: nil,
                     hasNext: models.count >= messageIds.count,
                     cache: true,
                     subjectId: conversationId,
                     time: nil,
                     typeCode: typeCode)
    }
}

extension ChatResponse<ReactionMessageResponse> {
    func toCacheModel(action: ReactionCountAction, myId: Int?) -> CacheReactionCountModel {
        CacheReactionCountModel(action: action,
                                messageId: result?.messageId ?? -1,
                                reaction: result?.reaction,
                                oldSticker: result?.oldSticker,
                                myUserId: myId ?? -1)
    }
}
