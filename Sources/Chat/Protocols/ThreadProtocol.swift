//
// ThreadProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatDTO
import ChatModels
import Foundation

@ChatGlobalActor
public protocol ThreadProtocol: AnyObject {
    /// Accessing to participants of a thread.
    var participant: ParticipantProtocol { get }

    /// Archive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    func archive(_ request: GeneralSubjectIdRequest)

    /// Unarchive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    func unarchive(_ request: GeneralSubjectIdRequest)

    /// Change a type of thread.
    /// - Parameters:
    ///   - request: The request that contains threadId and type of desierd thread.
    func changeType(_ request: ChangeThreadTypeRequest)

    /// Close a thread.
    ///
    /// With the closing, a thread participants of it can't send a message to it.
    /// - Parameters:
    ///   - request: Thread Id of the thread you want to be closed.
    func close(_ request: GeneralSubjectIdRequest)

    /// Create a thread.
    /// - Parameters:
    ///   - request: The request of create a thread.
    func create(_ request: CreateThreadRequest)

    /// Create thread with a message.
    /// - Parameters:
    ///   - request: The request with a message and threadId.
    func create(_ request: CreateThreadWithMessage)

    /// Create thread and send a file message.
    /// - Parameters:
    ///   - request: Request of craete thread.
    ///   - textMessage: Text message.
    func create(_ request: CreateThreadRequest, _ textMessage: SendTextMessageRequest)

    /// Delete a thread if you are admin in this thread.
    /// - Parameters:
    ///   - request: The request that contains thread id.
    func delete(_ request: GeneralSubjectIdRequest)

    /// Join to a public thread.
    /// - Parameters:
    ///   - request: Thread name of public thread.
    func join(_ request: JoinPublicThreadRequest)

    /// Leave a thread.
    /// - Parameters:
    ///   - request: The threadId if the thread with option to clear it's content.
    func leave(_ request: LeaveThreadRequest)

    /// Mute a thread when a new event happens.
    /// - Parameters:
    ///   - request: The request with a thread id.
    func mute(_ request: GeneralSubjectIdRequest)

    /// UNMute a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    func unmute(_ request: GeneralSubjectIdRequest)

    /// A list of mutual groups with a user.
    /// - Parameters:
    ///   - request: A request that contains a detail of a user invtee.
    func mutual(_ request: MutualGroupsRequest)

    /// Pin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    func pin(_ request: GeneralSubjectIdRequest)

    /// UNPin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    func unpin(_ request: GeneralSubjectIdRequest)

    /// Leave a thrad with replaceing admin.
    /// - Parameters:
    ///   - request: The request that contains threadId and participantId of new admin.
    func leaveSafely(_ request: SafeLeaveThreadRequest)

    /// Mark a thread as an spam
    ///
    /// A spammed thread can't send a message anymore.
    /// - Parameters:
    ///   - request: Request to spam a thread.
    func spam(_ request: GeneralSubjectIdRequest)

    /// Check name for the public thread is not occupied.
    /// - Parameters:
    ///   - request: The request for the name of the thread to check.
    func isNameAvailable(_ request: IsThreadNamePublicRequest)

    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    func get(_ request: ThreadsRequest)

    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    func unreadCount(_ request: ThreadsUnreadCountRequest)

    /// Update details of a thread.
    /// - Parameters:
    ///   - request: The request might contain an image, title, description, and a threadId.
    func updateInfo(_ request: UpdateThreadInfoRequest)

    /// Get sum of the all unread counts in all threads.
    /// - Parameters:
    ///   - request: The request can contain property to aggregate mute threads unread count.
    func allUnreadCount(_ request: AllThreadsUnreadCountRequest)

    /// Get the last action inside the conversation whether it's reaction or a message.
    /// - Parameters:
    ///   - request: List of conversation IDs to fetch last actions.
    func lastAction(_ request: LastActionInConversationRequest)
}

protocol InternalThreadProtocol: ThreadProtocol {
    func onUserRoles(_ asyncMessage: AsyncMessage)
}
