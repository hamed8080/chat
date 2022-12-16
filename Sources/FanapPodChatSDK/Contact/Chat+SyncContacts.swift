//
// Chat+SyncContacts.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Contacts
import FanapPodAsyncSDK
import Foundation

// Response
extension Chat {
    func requestSyncContacts(_ completion: @escaping CompletionType<[Contact]>, _ uniqueIdsResult: UniqueIdsResultType? = nil) {
        var contactsToSync: [AddContactRequest] = []
        authorizeContactAccess(grant: { [weak self] store in
            let phoneContacts = self?.getContactsFromAuthorizedStore(store)
            let cachePhoneContacts = PhoneContact.crud.getAll().map { $0.convertToContact() }
            phoneContacts?.forEach { phoneContact in
                if let findedContactCache = cachePhoneContacts.first(where: { $0.cellphoneNumber == phoneContact.cellphoneNumber }) {
                    if PhoneContact.isContactChanged(findedContactCache, phoneContactModel: phoneContact) {
                        contactsToSync.append(phoneContact.convertToAddRequest())
                    }
                } else {
                    contactsToSync.append(phoneContact.convertToAddRequest())
                }
            }
            var uniqueIds: [String] = []
            contactsToSync.forEach { contact in
                uniqueIds.append(contact.uniqueId)
            }
            if contactsToSync.count <= 0 { return }

            self?.requestAddContacts(contactsToSync) { [weak self] (response: ChatResponse<[Contact]>) in
                completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error))
                PhoneContact.updateOrInsertPhoneBooks(contacts: contactsToSync)
                self?.cache.save()
            }
            uniqueIdsResult?(uniqueIds)

        }, errorResult: { [weak self] error in
            self?.logger?.log(title: "authorize error", message: "\(error)")
        })
    }

    func getContactsFromAuthorizedStore(_ store: CNContactStore) -> [PhoneContactModel] {
        var phoneContacts: [PhoneContactModel] = []
        let keys = [CNContactGivenNameKey,
                    CNContactFamilyNameKey,
                    CNContactPhoneNumbersKey,
                    CNContactEmailAddressesKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])

        try? store.enumerateContacts(with: request, usingBlock: { contact, _ in
            var phoneContactModel = PhoneContactModel()
            phoneContactModel.cellphoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
            phoneContactModel.firstName = contact.givenName
            phoneContactModel.lastName = contact.familyName
            phoneContactModel.email = contact.emailAddresses.first?.value as String?
            phoneContacts.append(phoneContactModel)
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
extension Chat {
    func onSyncContacts(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        cache.write(cacheType: .syncedContacts)
        cache.save()
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .contactSynced)
    }
}
