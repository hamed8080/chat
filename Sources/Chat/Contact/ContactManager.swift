//
// ContactManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatExtensions
import ChatModels
import Contacts
import Foundation

final class ContactManager: ContactProtocol {
    let chat: ChatInternalProtocol

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    public func sync() {
        authorizeContactAccess(grant: { [weak self] store in
            Task {
                await self?.getContactsFromAuthorizedStore(store) { [weak self] phoneContacts in
                    Task {
                        await self?.syncWithCache(phoneContacts)
                    }
                }
            }
        }, errorResult: { [weak self] error in
            Task {
                await self?.onSyncError(error: error)
            }
        })
    }
    
    private func onSyncError(error: Error) {
        chat.logger.createLog(message: "UNAuthorized Access to Contact API with error: \(error.localizedDescription)", persist: true, level: .error, type: .received, userInfo: chat.loggerUserInfo)
    }

    private func syncWithCache(_ phoneContacts: [Contact]) {
        let contactCache = chat.cache?.contact
        Task { @MainActor in
            let contactEntities = contactCache?.all().compactMap({$0.codable})
            if let contactsToSync = contactEntities?.toSyncContactsRequest(newContacts: phoneContacts) {
                await addAll(contactsToSync)
            }
        }
    }

    func getContactsFromAuthorizedStore(_ store: CNContactStore, completion: @escaping (@Sendable ([Contact]) -> Void)) {
        let keys = contactKeys
        DispatchQueue.global(qos: .background).async {
            var phoneContacts: [Contact] = []
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            try? store.enumerateContacts(with: request, usingBlock: { cnContact, _ in
                phoneContacts.append(cnContact.toContact())
            })
            completion(phoneContacts)
        }
    }

    func authorizeContactAccess(grant: @escaping @Sendable (CNContactStore) -> Void, errorResult: (@Sendable (Error) -> Void)? = nil) {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            if let error = error {
                errorResult?(error)
                return
            }
            if granted {
                grant(store)
            }
        }
    }

    func onSyncContacts(_ asyncMessage: AsyncMessage) {
        guard let response = asyncMessage.chatMessage else { return }
        emitEvent(.contact(.synced(.init(result: response, typeCode: response.typeCode))))
    }

    func remove(_ request: RemoveContactsRequest) {
        let url = "\(chat.config.platformHost)\(Routes.removeContacts.rawValue)"
        let removeRequest = request
        let typeCode = request.toTypeCode(chat)
        let urlReq = request.toURLReq(url, chat.config.token, typeCode)
        chat.logger.logHTTPRequest(urlReq, String(describing: type(of: Bool.self)), persist: true, type: .sent)
        chat.session.dataTask(urlReq) { [weak self] data, urlResponse, error in
            Task {
                let tuple = (data: data, urlResponse: urlResponse, error: error, typeCode: typeCode, request: removeRequest)
                await self?.onRemoveContactsResult(tuple: tuple)
            }
        }
        .resume()
    }
    
    private func onRemoveContactsResult(tuple: RemovedContactData) {
        chat.logger.logHTTPResponse(tuple.data, tuple.urlResponse, tuple.error, persist: true, type: .received, userInfo: chat.loggerUserInfo)
        let tuple = toRemoveContactRevent(removeData: tuple)
        emitEvent(tuple.event)
        if tuple.removeResp?.deteled == true {
            chat.cache?.contact?.batchDelete([tuple.contactId])
        }
    }

    func onUsersLastSeen(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[UserLastSeenDuration]> = asyncMessage.toChatResponse()
        emitEvent(.contact(.contactsLastSeen(response)))
    }

    func get(_ request: ContactsRequest) {
        chat.prepareToSendAsync(req: request, type: .getContacts)
        let typeCode = request.toTypeCode(chat)
        let contactCache = chat.cache?.contact
        Task { @MainActor in
            if let (contacts, _) = contactCache?.getContacts(request.fetchRequest) {
                emitEvent(event: contacts.toCachedContactsEvent(request, typeCode))
            }
        }
    }

    func search(_ request: ContactsRequest) {
        get(request)
    }

    func onContacts(_ asyncMessage: AsyncMessage) async {
        let response: ChatResponse<[Contact]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        let copies = response.result?.compactMap{$0} ?? []
        await chat.cache?.contact?.insertContacts(models: copies)
        emitEvent(.contact(.contacts(response)))
    }

    func notSeen(_ request: NotSeenDurationRequest) {
        chat.prepareToSendAsync(req: request, type: .getNotSeenDuration)
    }

    func onContactNotSeen(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[ContactNotSeenDurationRespoonse]> = asyncMessage.toChatResponse()
        emitEvent(.contact(.notSeen(response)))
    }

    func getBlockedList(_ request: BlockedListRequest) {
        chat.prepareToSendAsync(req: request, type: .getBlocked)
    }

    func onBlockedContacts(_ asyncMessage: AsyncMessage) async {
        let response: ChatResponse<[BlockedContactResponse]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        await chat.cache?.contact?.insertContacts(models: response.result?.compactMap(\.contact) ?? [])
        emitEvent(.contact(.blockedList(response)))
    }

    func block(_ request: BlockRequest) {
        chat.prepareToSendAsync(req: request, type: .block)
    }

    func unBlock(_ request: UnBlockRequest) {
        chat.prepareToSendAsync(req: request, type: .unblock)
    }

    func onBlockUnBlockContact(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<BlockedContactResponse> = asyncMessage.toChatResponse()
        let isBlock = asyncMessage.chatMessage?.type == .block
        chat.cache?.contact?.block(isBlock, response.result?.contact?.id ?? -1)
        emitEvent(.contact(isBlock ? .blocked(response) : .unblocked(response)))
    }

    func add(_ request: AddContactRequest) {
        let url = "\(chat.config.platformHost)\(Routes.addContacts.rawValue)"
        let typeCode = chat.config.typeCodes[request.typeCodeIndex].typeCode
        let urlReq = request.toAddReq(url, chat.config.token, typeCode)
        chat.logger.logHTTPRequest(urlReq, String(describing: type(of: [Contact].self)), persist: true, type: .sent)
        chat.session.dataTask(urlReq) { [weak self] data, response, error in
            Task {
                await self?.onAddContacts(uniqueId: request.uniqueId, data: data, response: response, error: error)
            }
        }
        .resume()
    }

    func addAll(_ request: [AddContactRequest]) {
        let url = "\(chat.config.platformHost)\(Routes.addContacts.rawValue)"
        guard let urlReq = request.toAddAllReq(url: url, token: chat.config.token) else { return }
        chat.logger.logHTTPRequest(urlReq, String(describing: type(of: [Contact].self)), persist: true, type: .sent)
        chat.session.dataTask(urlReq) { [weak self] data, response, error in
            Task {
                await self?.onAddContacts(uniqueId: request.first?.uniqueId, data: data, response: response, error: error)
            }
        }
        .resume()
    }

    private func onAddContacts(uniqueId: String?, data: Data?, response: URLResponse?, error: Error?) async {
        let result: ChatResponse<ContactResponse>? = data?.decode(response, error, typeCode: nil)
        chat.logger.logHTTPResponse(data, response, error, persist: true, type: .received, userInfo: chat.loggerUserInfo)
        let response = ChatResponse(uniqueId: uniqueId, result: result?.result?.contacts, error: result?.error, typeCode: result?.typeCode)
        emitEvent(.contact(.add(response)))
        await chat.cache?.contact?.insertContacts(models: result?.result?.contacts ?? [])
    }
    
    private nonisolated func emitEvent(event: ChatEventType) {
        Task { @ChatGlobalActor [weak self] in
            self?.emitEvent(event)
        }
    }
    
    private func emitEvent(_ event: ChatEventType) {
        chat.delegate?.chatEvent(event: event)
    }
}

extension CNContactStore: @retroactive @unchecked Sendable {}
