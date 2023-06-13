//
// ContactManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation
import Contacts
import ChatExtensions

final class ContactManager: ContactProtocol {
    let chat: ChatInternalProtocol

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    // ❌❌❌❌❌❌❌❌❌❌ It has a problem with the core server. If you update a contact it will not appears as a contact in the getCntacts method.
    // Update a particular contact.
    //
    // Update name or other details of a contact.
    // - Parameters:
    //   - req: The request of what you need to be updated.
    //   - completion: The list of updated contacts.
    //   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    //    func updateContact(_ request: UpdateContactRequest, completion: @escaping CompletionType<[Contact]>, uniqueIdsResult _: UniqueIdResultType? = nil) {
    //        let url = "\(chat.config.platformHost)\(Routes.updateContacts.rawValue)"
    //        let headers: [String: String] = ["_token_": chat.config.token, "_token_issuer_": "1"]
    //        let bodyData = request.getParameterData()
    //        var urlReq = URLRequest(url: URL(string: url)!)
    //        urlReq.allHTTPHeaderFields = headers
    //        urlReq.httpBody = bodyData
    //        urlReq.method = .post
    //        chat.logger?.log(urlReq, String(describing: type(of: [Contact].self)))
    //        chat.session.dataTask(with: urlReq) { [weak self] data, response, error in
    //            self?.chat.logger?.log(data, response, error)
    //            let result: ChatResponse<ContactResponse>? = self?.chat.session.decode(data, response, error)
    //            self?.chat.responseQueue.async {
    //                completion(ChatResponse(uniqueId: request.uniqueId, result: result?.result?.contacts, error: result?.error))
    //            }
    //            self?.chat.cache?.contact?.insert(models: result?.result?.contacts ?? [])
    //        }
    //        .resume()
    //    }

    public func sync() {
        var contactsToSync: [AddContactRequest] = []
        authorizeContactAccess(grant: { [weak self] store in
            let phoneContacts = self?.getContactsFromAuthorizedStore(store)
            self?.chat.cache?.contact?.all { [weak self] contactEntities in
                guard let self = self else { return }
                self.chat.responseQueue.async {
                    phoneContacts?.forEach { phoneContact in
                        if let findedContactchat = contactEntities.first(where: { $0.cellphoneNumber == phoneContact.cellphoneNumber }) {
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
                    if contactsToSync.count <= 0 { return }
                    self.addAll(contactsToSync)
                }
            }
        }, errorResult: { [weak self] error in
            self?.chat.logger.createLog(message: "UNAuthorized Access to Contact API with error: \(error.localizedDescription)", persist: true, level: .error, type: .received, userInfo: self?.chat.loggerUserInfo)
        })
    }

    func getContactsFromAuthorizedStore(_ store: CNContactStore) -> [Contact] {
        var phoneContacts: [Contact] = []
        let keys = [CNContactGivenNameKey,
                    CNContactFamilyNameKey,
                    CNContactPhoneNumbersKey,
                    CNContactEmailAddressesKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])

        try? store.enumerateContacts(with: request, usingBlock: { contact, _ in
            let contactModel = Contact()
            contactModel.cellphoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
            contactModel.firstName = contact.givenName
            contactModel.lastName = contact.familyName
            contactModel.email = contact.emailAddresses.first?.value as String?
            phoneContacts.append(contactModel)
        })
        return phoneContacts
    }

    func authorizeContactAccess(grant: @escaping (CNContactStore) -> Void, errorResult: ((Error) -> Void)? = nil) {
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
        chat.delegate?.chatEvent(event: .contact(.synced(.init(result: response))))
    }

    func remove(_ request: RemoveContactsRequest) {
        let url = "\(chat.config.platformHost)\(Routes.removeContacts.rawValue)"
        let headers: [String: String] = ["_token_": chat.config.token, "_token_issuer_": "1"]
        let bodyData = request.parameterData
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        urlReq.method = .post
        chat.logger.logHTTPRequest(urlReq, String(describing: type(of: Bool.self)), persist: true, type: .sent)
        chat.session.dataTask(urlReq) { [weak self] data, urlResponse, error in
            let response: ChatResponse<RemoveContactResponse>? = self?.chat.session.decode(data, urlResponse, error)
            self?.chat.responseQueue.async {
                self?.chat.logger.logHTTPResponse(data, urlResponse, error, persist: true, type: .received, userInfo: self?.chat.loggerUserInfo)
                let deletedContacts = [Contact(id: request.contactId)]
                let chatResponse = ChatResponse(uniqueId: request.uniqueId, result: deletedContacts, error: response?.error)
                self?.chat.delegate?.chatEvent(event: .contact(.delete(chatResponse, deleted: response?.result?.deteled ?? false)))
                self?.removeFromCacheIfExist(removeContactResponse: response?.result, contactId: request.contactId)
            }
        }
        .resume()
    }

    func removeFromCacheIfExist(removeContactResponse: RemoveContactResponse?, contactId: Int) {
        if removeContactResponse?.deteled == true {
            chat.cache?.contact?.batchDelete([contactId])
        }
    }

    func onUsersLastSeen(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[UserLastSeenDuration]> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .contact(.contactsLastSeen(response)))
    }

    func get(_ request: ContactsRequest) {
        chat.prepareToSendAsync(req: request, type: .getContacts)
        chat.cache?.contact?.getContacts(request.fetchRequest) { [weak self] contacts, totalCount in
            let contacts = contacts.map(\.codable)
            self?.chat.responseQueue.async {
                let pagination = PaginationWithContentCount(hasNext: contacts.count >= request.size, count: request.size, offset: request.offset, totalCount: totalCount)
                let reponse = ChatResponse(uniqueId: request.uniqueId, result: contacts, cache: true, pagination: pagination)
                self?.chat.delegate?.chatEvent(event: .contact(.contacts(reponse)))
            }
        }
    }

    func search(_ request: ContactsRequest) {
        get(request)
    }

    func onContacts(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Contact]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        chat.cache?.contact?.insert(models: response.result ?? [])
        chat.delegate?.chatEvent(event: .contact(.contacts(response)))
    }

    func notSeen(_ request: NotSeenDurationRequest) {
        chat.prepareToSendAsync(req: request, type: .getNotSeenDuration)
    }

    func onContactNotSeen(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[ContactNotSeenDurationRespoonse]> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .contact(.notSeen(response)))
    }

    func getBlockedList(_ request: BlockedListRequest) {
        chat.prepareToSendAsync(req: request, type: .getBlocked)
    }

    func onBlockedContacts(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[BlockedContactResponse]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        chat.cache?.contact?.insert(models: response.result?.compactMap(\.contact) ?? [])
        chat.delegate?.chatEvent(event: .contact(.blockedList(response)))
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
        chat.delegate?.chatEvent(event: .contact(isBlock ? .blocked(response) : .unblocked(response)))
    }

    func add(_ request: AddContactRequest) {
        let url = "\(chat.config.platformHost)\(Routes.addContacts.rawValue)"
        let headers: [String: String] = ["_token_": chat.config.token, "_token_issuer_": "1", "Content-Type": "application/x-www-form-urlencoded"]
        let bodyData = request.parameterData
        var urlReq = URLRequest(url: URL(string: url)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.httpBody = bodyData
        urlReq.method = .post
        chat.logger.logHTTPRequest(urlReq, String(describing: type(of: [Contact].self)), persist: true, type: .sent)
        chat.session.dataTask(urlReq) { [weak self] data, response, error in
            self?.onAddContacts(uniqueId: request.uniqueId, data: data, response: response, error: error)
        }
        .resume()
    }

    func addAll(_ request: [AddContactRequest]) {
        let url = "\(chat.config.platformHost)\(Routes.addContacts.rawValue)"
        var urlComp = URLComponents(string: url)!
        urlComp.queryItems = []
        request.forEach { contact in

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
        guard let urlString = urlComp.string else { return }
        let headers: [String: String] = ["_token_": chat.config.token, "_token_issuer_": "1", "Content-Type": "application/x-www-form-urlencoded"]
        var urlReq = URLRequest(url: URL(string: urlString)!)
        urlReq.allHTTPHeaderFields = headers
        urlReq.method = .post
        chat.logger.logHTTPRequest(urlReq, String(describing: type(of: [Contact].self)), persist: true, type: .sent)
        chat.session.dataTask(urlReq) { [weak self] data, response, error in
            self?.onAddContacts(uniqueId: request.first?.uniqueId, data: data, response: response, error: error)
        }
        .resume()
    }

    private func onAddContacts(uniqueId: String?, data: Data?, response: URLResponse?, error: Error?) {
        let result: ChatResponse<ContactResponse>? = chat.session.decode(data, response, error)
        chat.responseQueue.async { [weak self] in
            self?.chat.logger.logHTTPResponse(data, response, error, persist: true, type: .received, userInfo: self?.chat.loggerUserInfo)
            let response = ChatResponse(uniqueId: uniqueId, result: result?.result?.contacts, error: result?.error)
            self?.chat.delegate?.chatEvent(event: .contact(.add(response)))
        }
        chat.cache?.contact?.insert(models: result?.result?.contacts ?? [])
    }

}
