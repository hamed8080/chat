//
// ContactProtocols.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

public protocol ContactProtocols {
    /// Add a new contact.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request if the contact is added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func addContact(_ request: AddContactRequest, completion: @escaping CompletionType<[Contact]>, uniqueIdResult _: UniqueIdResultType?)

    /// Add multiple contacts at once.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request if the contacts are added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func addContacts(_ request: [AddContactRequest], completion: @escaping CompletionType<[Contact]>, uniqueIdsResult: UniqueIdsResultType?)

    /// Block a specific contact.
    /// - Parameters:
    ///   - request: You could block contact with userId, contactId or you could block a thread.
    ///   - completion: Reponse of blocked request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func blockContact(_ request: BlockRequest, completion: @escaping CompletionType<Contact>, uniqueIdResult: UniqueIdResultType?)

    /// Unblock a blcked contact.
    /// - Parameters:
    ///   - request: You could unblock contact with userId, contactId or you could unblock a thread.
    ///   - completion: Reponse of before blocked request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unBlockContact(_ request: UnBlockRequest, completion: @escaping CompletionType<Contact>, uniqueIdResult: UniqueIdResultType?)

    /// Get the list of blocked contacts.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer is the list of blocked contacts.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getBlockedContacts(_ request: BlockedListRequest, completion: @escaping CompletionType<[Contact]>, uniqueIdResult: UniqueIdResultType?)

    /// Check the last time a user opened the application.
    /// - Parameters:
    ///   - request: The request with userIds.
    ///   - completion: List of last seen users with time attached to each item.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func contactNotSeen(_ request: NotSeenDurationRequest, completion: @escaping CompletionType<[UserLastSeenDuration]>, uniqueIdResult: UniqueIdResultType?)

    /// Get contacts of current user.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request.
    ///   - cacheResponse: Reponse from cache database.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getContacts(_ request: ContactsRequest, completion: @escaping CompletionType<[Contact]>, cacheResponse: CacheResponseType<[Contact]>?, uniqueIdResult: UniqueIdResultType?)

    /// Search inside contacts.
    ///
    /// You could search inside the list of contacts by email, cell phone number, or a query or a specific id.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer if the contact has been successfully deleted.
    ///   - cacheResponse: Reponse from cache database.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func searchContacts(_ request: ContactsRequest, completion: @escaping CompletionType<[Contact]>, cacheResponse: CacheResponseType<[Contact]>?, uniqueIdResult: UniqueIdResultType?)

    /// Remove a contact from your circle of contacts.
    /// - Parameters:
    ///   - request: The request with userIds.
    ///   - completion: The answer if the contact has been successfully deleted.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func removeContact(_ request: RemoveContactsRequest, completion: @escaping CompletionType<Bool>, uniqueIdResult _: UniqueIdResultType?)

    /// Sync contacts with server.
    ///
    /// If a new contact is added to your device it'll sync the unsynced contacts.
    /// - Parameters:
    ///   - completion: The answer of synced contacts.
    ///   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func syncContacts(completion: @escaping CompletionType<[Contact]>, uniqueIdsResult: UniqueIdsResultType?)
}

public extension ContactProtocols {
    /// Add a new contact.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request if the contact is added successfully.
    func addContact(_ request: AddContactRequest, completion: @escaping CompletionType<[Contact]>) {
        addContact(request, completion: completion, uniqueIdResult: nil)
    }

    /// Add multiple contacts at once.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request if the contacts are added successfully.
    func addContacts(_ request: [AddContactRequest], completion: @escaping CompletionType<[Contact]>) {
        addContacts(request, completion: completion, uniqueIdsResult: nil)
    }

    /// Block a specific contact.
    /// - Parameters:
    ///   - request: You could block contact with userId, contactId or you could block a thread.
    ///   - completion: Reponse of blocked request.
    func blockContact(_ request: BlockRequest, completion: @escaping CompletionType<Contact>) {
        blockContact(request, completion: completion, uniqueIdResult: nil)
    }

    /// Unblock a blcked contact.
    /// - Parameters:
    ///   - request: You could unblock contact with userId, contactId or you could unblock a thread.
    ///   - completion: Reponse of before blocked request.
    func unBlockContact(_ request: UnBlockRequest, completion: @escaping CompletionType<Contact>) {
        unBlockContact(request, completion: completion, uniqueIdResult: nil)
    }

    /// Get the list of blocked contacts.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer is the list of blocked contacts.
    func getBlockedContacts(_ request: BlockedListRequest, completion: @escaping CompletionType<[Contact]>) {
        getBlockedContacts(request, completion: completion, uniqueIdResult: nil)
    }

    /// Check the last time a user opened the application.
    /// - Parameters:
    ///   - request: The request with userIds.
    ///   - completion: List of last seen users with time attached to each item.
    func contactNotSeen(_ request: NotSeenDurationRequest, completion: @escaping CompletionType<[UserLastSeenDuration]>) {
        contactNotSeen(request, completion: completion, uniqueIdResult: nil)
    }

    /// Get contacts of current user.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer of the request.
    ///   - cacheResponse: Reponse from cache database.
    func getContacts(_ request: ContactsRequest, completion: @escaping CompletionType<[Contact]>, cacheResponse: CacheResponseType<[Contact]>?) {
        getContacts(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Search inside contacts.
    ///
    /// You could search inside the list of contacts by email, cell phone number, or a query or a specific id.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer if the contact has been successfully deleted.
    ///   - cacheResponse: Reponse from cache database.
    func searchContacts(_ request: ContactsRequest, completion: @escaping CompletionType<[Contact]>, cacheResponse: CacheResponseType<[Contact]>?) {
        searchContacts(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Search inside contacts.
    ///
    /// You could search inside the list of contacts by email, cell phone number, or a query or a specific id.
    /// - Parameters:
    ///   - request: The request.
    ///   - completion: The answer if the contact has been successfully deleted.
    func searchContacts(_ request: ContactsRequest, completion: @escaping CompletionType<[Contact]>) {
        searchContacts(request, completion: completion, cacheResponse: nil, uniqueIdResult: nil)
    }

    /// Remove a contact from your circle of contacts.
    /// - Parameters:
    ///   - request: The request with userIds.
    ///   - completion: The answer if the contact has been successfully deleted.
    func removeContact(_ request: RemoveContactsRequest, completion: @escaping CompletionType<Bool>) {
        removeContact(request, completion: completion, uniqueIdResult: nil)
    }

    /// Sync contacts with server.
    ///
    /// If a new contact is added to your device it'll sync the unsynced contacts.
    /// - Parameters:
    ///   - completion: The answer of synced contacts.
    func syncContacts(completion: @escaping CompletionType<[Contact]>) {
        syncContacts(completion: completion, uniqueIdsResult: nil)
    }
}
