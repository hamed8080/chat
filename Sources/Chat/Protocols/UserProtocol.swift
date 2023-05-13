//
// UserProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

public protocol UserProtocol {
    /// Tell the server user has logged out. This method wil **truncate and delete** all data inside the cache.
    func logOut()

    /// Remove set of roles from a participant.
    /// - Parameters:
    ///   - request: A request that contains a set of roles and a threadId.
    ///   - completion: List of removed roles for a participant.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func removeRoles(_ request: RolesRequest, completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType?)

    /// Remove a participant auditor access roles.
    /// - Parameters:
    ///   - request: A request that contains a threadId and roles of user with userId.
    ///   - completion: List of roles that removed roles for the users.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func removeAuditor(_ request: AuditorRequest, completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType?)

    /// Send Status ping.
    /// - Parameter request: Send type of ping.
    func sendStatusPing(_ request: SendStatusPingRequest)

    /// Update current user details.
    /// - Parameters:
    ///   - request: The request that contains bio and metadata.
    ///   - completion: New profile response.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func setProfile(_ request: UpdateChatProfile, completion: @escaping CompletionType<Profile>, uniqueIdResult: UniqueIdResultType?)

    /// Getting current user details.
    /// - Parameters:
    ///   - request: The request:
    ///   - completion: Response of the request.
    ///   - cacheResponse: cache response for the current user.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getUserInfo(_ request: UserInfoRequest, completion: @escaping CompletionType<User>, cacheResponse: CacheResponseType<User>?, uniqueIdResult: UniqueIdResultType?)

    /// Set a set of roles to a participant of a thread.
    /// - Parameters:
    ///   - request: A request that contains a set of roles and a threadId.
    ///   - completion: List of applied roles for a participant.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func setRoles(_ request: RolesRequest, completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType?)

    /// Set a participant auditor access roles.
    /// - Parameters:
    ///   - request: A request that contains a threadId and roles of user with userId.
    ///   - completion: List of roles that applied for the users.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func setAuditor(_ request: AuditorRequest, completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType?)

    /// Get the roles of the current user in a thread.
    /// - Parameters:
    ///   - request: A request that contains a threadId.
    ///   - completion: List of the roles of a user.
    ///   - cacheResponse: The cache response of roles.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getCurrentUserRoles(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<[Roles]>, cacheResponse: CacheResponseType<[Roles]>?, uniqueIdResult: UniqueIdResultType?)
}

public extension UserProtocol {
    /// Remove set of roles from a participant.
    /// - Parameters:
    ///   - request: A request that contains a set of roles and a threadId.
    ///   - completion: List of removed roles for a participant.
    func removeRoles(_ request: RolesRequest, completion: @escaping CompletionType<[UserRole]>) {
        removeRoles(request, completion: completion, uniqueIdResult: nil)
    }

    /// Remove a participant auditor access roles.
    /// - Parameters:
    ///   - request: A request that contains a threadId and roles of user with userId.
    ///   - completion: List of roles that removed roles for the users.
    func removeAuditor(_ request: AuditorRequest, completion: @escaping CompletionType<[UserRole]>) {
        removeAuditor(request, completion: completion, uniqueIdResult: nil)
    }

    /// Update current user details.
    /// - Parameters:
    ///   - request: The request that contains bio and metadata.
    ///   - completion: New profile response.
    func setProfile(_ request: UpdateChatProfile, completion: @escaping CompletionType<Profile>) {
        setProfile(request, completion: completion, uniqueIdResult: nil)
    }

    /// Getting current user details.
    /// - Parameters:
    ///   - request: The request:
    ///   - completion: Response of the request.
    ///   - cacheResponse: cache response for the current user.
    func getUserInfo(_ request: UserInfoRequest, completion: @escaping CompletionType<User>, cacheResponse: CacheResponseType<User>?) {
        getUserInfo(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Set a set of roles to a participant of a thread.
    /// - Parameters:
    ///   - request: A request that contains a set of roles and a threadId.
    ///   - completion: List of applied roles for a participant.
    func setRoles(_ request: RolesRequest, completion: @escaping CompletionType<[UserRole]>, uniqueIdResult _: UniqueIdResultType?) {
        setRoles(request, completion: completion, uniqueIdResult: nil)
    }

    /// Set a participant auditor access roles.
    /// - Parameters:
    ///   - request: A request that contains a threadId and roles of user with userId.
    ///   - completion: List of roles that applied for the users.
    func setAuditor(_ request: AuditorRequest, completion: @escaping CompletionType<[UserRole]>) {
        setAuditor(request, completion: completion, uniqueIdResult: nil)
    }

    /// Get the roles of the current user in a thread.
    /// - Parameters:
    ///   - request: A request that contains a threadId.
    ///   - completion: List of the roles of a user.
    ///   - cacheResponse: The cache response of roles.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getCurrentUserRoles(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<[Roles]>, cacheResponse: CacheResponseType<[Roles]>?, uniqueIdResult _: UniqueIdResultType?) {
        getCurrentUserRoles(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }
}
