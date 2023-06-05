//
// ChatImplementation+SyncContacts.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Contacts
import Foundation

// Response
extension ChatImplementation {
    /// Sync contacts with server.
    ///
    /// If a new contact is added to your device it'll sync the unsynced contacts.
    /// - Parameters:
    ///   - completion: The answer of synced contacts.
    ///   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    public func syncContacts(completion: @escaping CompletionType<[Contact]>, uniqueIdsResult: UniqueIdsResultType? = nil) {
        var contactsToSync: [AddContactRequest] = []
        authorizeContactAccess(grant: { [weak self] store in
            let phoneContacts = self?.getContactsFromAuthorizedStore(store)
            self?.cache?.contact?.all { [weak self] contactEntities in
                guard let self = self else { return }
                self.responseQueue.async {
                    phoneContacts?.forEach { phoneContact in
                        if let findedContactCache = contactEntities.first(where: { $0.cellphoneNumber == phoneContact.cellphoneNumber }) {
                            if findedContactCache.isContactChanged(contact: phoneContact) {
                                contactsToSync.append(phoneContact.request)
                            }
                        } else {
                            contactsToSync.append(phoneContact.request)
                        }
                    }
                    var uniqueIds: [String] = []
                    contactsToSync.forEach { contact in
                        uniqueIds.append(contact.uniqueId ?? UUID().uuidString)
                    }
                    if contactsToSync.count <= 0 { return }

                    self.addContacts(contactsToSync) { [weak self] (response: ChatResponse<[Contact]>) in
                        completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error))
                        self?.cache?.contact?.insert(models: response.result ?? [])
                    }
                    uniqueIdsResult?(uniqueIds)
                }
            }
        }, errorResult: { [weak self] error in
            self?.logger.createLog(message: "UNAuthorized Access to Contact API with error: \(error.localizedDescription)", persist: true, level: .error, type: .received, userInfo: self?.loggerUserInfo)
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
}

// Response
extension ChatImplementation {
    func onSyncContacts(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .contactSynced)
    }
}
