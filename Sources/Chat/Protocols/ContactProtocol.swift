//
// ContactProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

public protocol ContactProtocol {
    /// Add a new contact.
    /// - Parameters:
    ///   - request: The request.
    func add(_ request: AddContactRequest)

    /// Add multiple contacts at once.
    /// - Parameters:
    ///   - request: The request.
    func addAll(_ request: [AddContactRequest])

    /// Block a specific contact.
    /// - Parameters:
    ///   - request: You could block contact with userId, contactId or you could block a thread.
    func block(_ request: BlockRequest)

    /// Unblock a blcked contact.
    /// - Parameters:
    ///   - request: You could unblock contact with userId, contactId or you could unblock a thread.
    func unBlock(_ request: UnBlockRequest)

    /// Get the list of blocked contacts.
    /// - Parameters:
    ///   - request: The request.
    func getBlockedList(_ request: BlockedListRequest)

    /// Check the last time a user opened the application.
    /// - Parameters:
    ///   - request: The request with userIds.
    func notSeen(_ request: NotSeenDurationRequest)

    /// Get contacts of current user.
    /// - Parameters:
    ///   - request: The request.
    func get(_ request: ContactsRequest)

    /// Search inside contacts.
    ///
    /// You could search inside the list of contacts by email, cell phone number, or a query or a specific id.
    /// - Parameters:
    ///   - request: The request.
    func search(_ request: ContactsRequest)

    /// Remove a contact from your circle of contacts.
    /// - Parameters:
    ///   - request: The request with userIds.
    func remove(_ request: RemoveContactsRequest)

    /// Sync contacts with server.
    ///
    /// If a new contact is added to your device it'll sync the unsynced contacts.
    /// - Parameters:
    func sync()
}

public extension ContactProtocol {
    func getBlockedList(_ request: BlockedListRequest = .init()) {
        getBlockedList(request)
    }
}
