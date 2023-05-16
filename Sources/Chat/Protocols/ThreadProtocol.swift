//
// ThreadProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

public protocol ThreadProtocol {
    /// Add participant to a thread.
    /// - Parameters:
    ///   - request: Fill in the appropriate initializer.
    ///   - completion: Reponse of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func addParticipant(_ request: AddParticipantRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType?)

    /// Add threads to a tag.
    /// - Parameters:
    ///   - request: The tag id and list of threads id.
    ///   - completion: The response of the request which contains list of tagParticipants added.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func addTagParticipants(_ request: AddTagParticipantsRequest, completion: @escaping CompletionType<[TagParticipant]>, uniqueIdResult: UniqueIdResultType?)

    /// Archive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    ///   - completion: A response which contain the threadId of archived thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func archiveThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType?)

    /// Unarchive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    ///   - completion: A response which contain the threadId of unarchived thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unarchiveThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType?)

    /// Get list of assistants for user.
    /// - Parameters:
    ///   - request: A request with a contact type and offset, count.
    ///   - completion: The list of assistants.
    ///   - cacheResponse: The cache response of list of assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getAssistats(_ request: AssistantsRequest, completion: @escaping CompletionType<[Assistant]>, cacheResponse: CompletionType<[Assistant]>?, uniqueIdResult: UniqueIdResultType?)

    /// Get a history of assitant actions.
    /// - Parameters:
    ///   - completion: The list of actions of an assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getAssistatsHistory(completion: @escaping CompletionType<[AssistantAction]>, uniqueIdResult: UniqueIdResultType?)

    /// Block assistants.
    /// - Parameters:
    ///   - request: A list of assistants you want to block them.
    ///   - completion: List of blocked assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func blockAssistants(_ request: BlockUnblockAssistantRequest, completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType?)

    /// UNBlock assistants.
    /// - Parameters:
    ///   - request: A list of assistants you want to unblock them.
    ///   - completion: List of unblocked assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unblockAssistants(_ request: BlockUnblockAssistantRequest, completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType?)

    /// Get list of blocked assistants.
    /// - Parameters:
    ///   - request: A request that contains an offset and count.
    ///   - completion: List of blocked assistants.
    ///   - cacheResponse: The cached version of blocked assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getBlockedAssistants(_ request: BlockedAssistantsRequest, completion: @escaping CompletionType<[Assistant]>, cacheResponse: CacheResponseType<[Assistant]>?, uniqueIdResult: UniqueIdResultType?)

    /// Change a type of thread.
    /// - Parameters:
    ///   - request: The request that contains threadId and type of desierd thread.
    ///   - completion: Response of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func changeThreadType(_ request: ChangeThreadTypeRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType?)

    /// Close a thread.
    ///
    /// With the closing, a thread participants of it can't send a message to it.
    /// - Parameters:
    ///   - request: Thread Id of the thread you want to be closed.
    ///   - completion: The id of the thread which closed.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func closeThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType?)

    /// Create a new tag.
    /// - Parameters:
    ///   - request: The name of the tag.
    ///   - completion: Response of the request if tag added successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func createTag(_ request: CreateTagRequest, completion: @escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType?)

    /// Create a thread.
    /// - Parameters:
    ///   - request: The request of create a thread.
    ///   - completion: Response to create thread which contains a ``Conversation`` that includes threadId and other properties.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func createThread(_ request: CreateThreadRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType?)

    /// Create thread with a message.
    /// - Parameters:
    ///   - request: The request with a message and threadId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Call when message is snet.
    ///   - onDelivery:  Call when message deliverd but not seen yet.
    ///   - onSeen: Call when message is seen.
    ///   - completion: Response of request and created thread.
    func createThreadWithMessage(_ request: CreateThreadWithMessage,
                                 uniqueIdResult: UniqueIdResultType?,
                                 onSent _: OnSentType?,
                                 onDelivery _: OnDeliveryType?,
                                 onSeen _: OnSentType?,
                                 completion: @escaping CompletionType<Conversation>)

    /// Create thread and send a file message.
    /// - Parameters:
    ///   - request: Request of craete thread.
    ///   - textMessage: Text message.
    ///   - uploadFile: File request.
    ///   - uploadProgress: Track the progress of uploading.
    ///   - onSent: Call when message is snet.
    ///   - onSeen: Call when message is seen.
    ///   - onDeliver: Call when message deliverd but not seen yet.
    ///   - createThreadCompletion: Call when the thread is created, and it's called before uploading gets completed
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func createThreadWithFileMessage(_ request: CreateThreadRequest,
                                     textMessage: SendTextMessageRequest,
                                     uploadFile: UploadFileRequest,
                                     uploadProgress: UploadFileProgressType?,
                                     onSent: OnSentType?,
                                     onSeen: OnSeenType?,
                                     onDeliver: OnDeliveryType?,
                                     createThreadCompletion: CompletionType<Conversation>?,
                                     uploadUniqueIdResult: UniqueIdResultType?,
                                     messageUniqueIdResult: UniqueIdResultType?)

    /// Deactivate assistants.
    /// - Parameters:
    ///   - request: A request that contains a list of activated assistants.
    ///   - completion: The result of deactivated assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deactiveAssistant(_ request: DeactiveAssistantRequest, completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType?)

    /// Delete a tag.
    /// - Parameters:
    ///   - request: The id of tag.
    ///   - completion: Response of the request if tag deleted successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deleteTag(_ request: DeleteTagRequest, completion: @escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType?)

    /// Delete a thread if you are admin in this thread.
    /// - Parameters:
    ///   - request: The request that contains thread id.
    ///   - completion: Result of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deleteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType?)

    /// Edit the tag name.
    /// - Parameters:
    ///   - request: The id of the tag and new name of the tag.
    ///   - completion: Response of the request if tag edited successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func editTag(_ request: EditTagRequest, completion: @escaping CompletionType<Tag>, uniqueIdResult: UniqueIdResultType?)

    /// Join to a public thread.
    /// - Parameters:
    ///   - request: Thread name of public thread.
    ///   - completion: Detail of public thread as a ``Conversation`` object.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func joinThread(_ request: JoinPublicThreadRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType?)

    /// Leave a thread.
    /// - Parameters:
    ///   - request: The threadId if the thread with option to clear it's content.
    ///   - completion: The response of the left thread..
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func leaveThread(_ request: LeaveThreadRequest, completion: @escaping CompletionType<User>, uniqueIdResult: UniqueIdResultType?)

    /// Mute a thread when a new event happens.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of mute thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func muteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType?)

    /// UNMute a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of unmute thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unmuteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType?)

    /// A list of mutual groups with a user.
    /// - Parameters:
    ///   - request: A request that contains a detail of a user invtee.
    ///   - completion: List of threads that are mutual between the current user and desired user.
    ///   - cacheResponse: The cached version of mutual groups.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func mutualGroups(_ request: MutualGroupsRequest, completion: @escaping CompletionType<[Conversation]>, cacheResponse: CacheResponseType<[Conversation]>?, uniqueIdResult: UniqueIdResultType?)

    /// Pin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of pin thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func pinThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType?)

    /// UNPin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of unpin thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unpinThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType?)

    /// Register a participant as an assistant.
    /// - Parameters:
    ///   - request: The request that contains list of assistants.
    ///   - completion: A list of assistant that added for the user.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func registerAssistat(_ request: RegisterAssistantRequest, completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType?)

    /// Remove participants from a thread.
    /// - Parameters:
    ///   - request: List of participants id and threadId.
    ///   - completion: Result of deleted participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func removeParticipants(_ request: RemoveParticipantsRequest, completion: @escaping CompletionType<[Participant]>, uniqueIdResult: UniqueIdResultType?)

    /// Remove tag participants from a tag.
    /// - Parameters:
    ///   - request: The tag id and the list of tag participants id.
    ///   - completion: List of removed tag participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func removeTagParticipants(_ request: RemoveTagParticipantsRequest, completion: @escaping CompletionType<[TagParticipant]>, uniqueIdResult: UniqueIdResultType?)

    /// Leave a thrad with replaceing admin.
    /// - Parameters:
    ///   - request: The request that contains threadId and participantId of new admin.
    ///   - completion: Result of request.
    ///   - newAdminCompletion: Result of new admin.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func leaveThreadSaftly(_ request: SafeLeaveThreadRequest, completion: @escaping CompletionType<User>, newAdminCompletion: CompletionType<[UserRole]>?, uniqueIdResult: UniqueIdResultType?)

    /// Mark a thread as an spam
    ///
    /// A spammed thread can't send a message anymore.
    /// - Parameters:
    ///   - request: Request to spam a thread.
    ///   - completion: Response of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func spamPvThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Contact>, uniqueIdResult: UniqueIdResultType?)

    /// List of Tags.
    /// - Parameters:
    ///   - uniqueId: The uniqueId of request if you want to set a specific one.
    ///   - completion: List of tags.
    ///   - cacheResponse: List of cached tags.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func tagList(_ uniqueId: String?, completion: @escaping CompletionType<[Tag]>, cacheResponse: CacheResponseType<[Tag]>?, uniqueIdResult: UniqueIdResultType?)

    /// Get the list of tag participants.
    /// - Parameters:
    ///   - request: The tag id.
    ///   - completion: List of tag participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getTagParticipants(_ request: GetTagParticipantsRequest, completion: @escaping CompletionType<[TagParticipant]>, uniqueIdResult: UniqueIdResultType?)

    /// Check name for the public thread is not occupied.
    /// - Parameters:
    ///   - request: The request for the name of the thread to check.
    ///   - completion: If thread name is free for using as public it will not be nil.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func isThreadNamePublic(_ request: IsThreadNamePublicRequest, completion: @escaping CompletionType<PublicThreadNameAvailableResponse>, uniqueIdResult: UniqueIdResultType?)

    /// Get thread participants.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    ///   - completion: Pagination list of participants.
    ///   - cacheResponse: Cache response of participants inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getThreadParticipants(_ request: ThreadParticipantsRequest, completion: @escaping CompletionType<[Participant]>, cacheResponse: CacheResponseType<[Participant]>?, uniqueIdResult: UniqueIdResultType?)

    /// Get thread participants.
    ///
    /// It's the same ``Chat/getThreadParticipants(_:completion:cacheResponse:uniqueIdResult:)`` only return admins.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    ///   - completion: Pagination list of participants.
    ///   - cacheResponse: Cache response of participants inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getThreadAdmins(_ request: ThreadParticipantsRequest, completion: @escaping CompletionType<[Participant]>, cacheResponse: CacheResponseType<[Participant]>?, uniqueIdResult: UniqueIdResultType?)

    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Threads list that came from the cache?.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getThreads(_ request: ThreadsRequest, completion: @escaping CompletionType<[Conversation]>, cacheResponse: CacheResponseType<[Conversation]>?, uniqueIdResult: UniqueIdResultType?)

    /// Getting the all threads.
    /// - Parameters:
    ///   - request: If you send the summary true in request the result only contains list of all thread ids which is much faster way to fetch thread list.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Thread cache return data from disk so it contains all data in each model.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getAllThreads(_ request: AllThreads, completion: @escaping CompletionType<[Int]>, cacheResponse: CacheResponseType<[Int]>?, uniqueIdResult: UniqueIdResultType?)

    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Threads list that came from the cache?.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getThreadsUnreadCount(_ request: ThreadsUnreadCountRequest, completion: @escaping CompletionType<[String: Int]>, cacheResponse: CacheResponseType<[String: Int]>?, uniqueIdResult: UniqueIdResultType?)

    /// Update details of a thread.
    /// - Parameters:
    ///   - request: The request might contain an image, title, description, and a threadId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - uploadProgress: Upload progrees if you update image of the thread.
    ///   - completion: Response of update.
    func updateThreadInfo(_ request: UpdateThreadInfoRequest, uniqueIdResult: UniqueIdResultType?, uploadProgress: @escaping UploadFileProgressType, completion: @escaping CompletionType<Conversation>)
}

public extension ThreadProtocol {
    /// Add participant to a thread.
    /// - Parameters:
    ///   - request: Fill in the appropriate initializer.
    ///   - completion: Reponse of request.
    func addParticipant(_ request: AddParticipantRequest, completion: @escaping CompletionType<Conversation>) {
        addParticipant(request, completion: completion, uniqueIdResult: nil)
    }

    /// Add threads to a tag.
    /// - Parameters:
    ///   - request: The tag id and list of threads id.
    ///   - completion: The response of the request which contains list of tagParticipants added.
    func addTagParticipants(_ request: AddTagParticipantsRequest, completion: @escaping CompletionType<[TagParticipant]>) {
        addTagParticipants(request, completion: completion, uniqueIdResult: nil)
    }

    /// Archive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    ///   - completion: A response which contain the threadId of archived thread.
    func archiveThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>) {
        archiveThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// Unarchive a thread.
    /// - Parameters:
    ///   - request: A request that contains the threadId.
    ///   - completion: A response which contain the threadId of unarchived thread.
    func unarchiveThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>) {
        unarchiveThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// Get list of assistants for user.
    /// - Parameters:
    ///   - request: A request with a contact type and offset, count.
    ///   - completion: The list of assistants.
    ///   - cacheResponse: The cache response of list of assistants.
    func getAssistats(_ request: AssistantsRequest, completion: @escaping CompletionType<[Assistant]>, cacheResponse: CompletionType<[Assistant]>?) {
        getAssistats(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Get a history of assitant actions.
    /// - Parameters:
    ///   - completion: The list of actions of an assistants.
    func getAssistatsHistory(completion: @escaping CompletionType<[AssistantAction]>) {
        getAssistatsHistory(completion: completion, uniqueIdResult: nil)
    }

    /// Block assistants.
    /// - Parameters:
    ///   - request: A list of assistants you want to block them.
    ///   - completion: List of blocked assistants.
    func blockAssistants(_ request: BlockUnblockAssistantRequest, completion: @escaping CompletionType<[Assistant]>) {
        blockAssistants(request, completion: completion, uniqueIdResult: nil)
    }

    /// UNBlock assistants.
    /// - Parameters:
    ///   - request: A list of assistants you want to unblock them.
    ///   - completion: List of unblocked assistants.
    func unblockAssistants(_ request: BlockUnblockAssistantRequest, completion: @escaping CompletionType<[Assistant]>) {
        unblockAssistants(request, completion: completion, uniqueIdResult: nil)
    }

    /// Get list of blocked assistants.
    /// - Parameters:
    ///   - request: A request that contains an offset and count.
    ///   - completion: List of blocked assistants.
    ///   - cacheResponse: The cached version of blocked assistants.
    func getBlockedAssistants(_ request: BlockedAssistantsRequest, completion: @escaping CompletionType<[Assistant]>, cacheResponse: CacheResponseType<[Assistant]>?) {
        getBlockedAssistants(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Change a type of thread.
    /// - Parameters:
    ///   - request: The request that contains threadId and type of desierd thread.
    ///   - completion: Response of the request.
    func changeThreadType(_ request: ChangeThreadTypeRequest, completion: @escaping CompletionType<Conversation>) {
        changeThreadType(request, completion: completion, uniqueIdResult: nil)
    }

    /// Close a thread.
    ///
    /// With the closing, a thread participants of it can't send a message to it.
    /// - Parameters:
    ///   - request: Thread Id of the thread you want to be closed.
    ///   - completion: The id of the thread which closed.
    func closeThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>) {
        closeThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// Create a new tag.
    /// - Parameters:
    ///   - request: The name of the tag.
    ///   - completion: Response of the request if tag added successfully.
    func createTag(_ request: CreateTagRequest, completion: @escaping CompletionType<Tag>) {
        createTag(request, completion: completion, uniqueIdResult: nil)
    }

    /// Create a thread.
    /// - Parameters:
    ///   - request: The request of create a thread.
    ///   - completion: Response to create thread which contains a ``Conversation`` that includes threadId and other properties.
    func createThread(_ request: CreateThreadRequest, completion: @escaping CompletionType<Conversation>) {
        createThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// Create thread with a message.
    /// - Parameters:
    ///   - request: The request with a message and threadId.
    func createThreadWithMessage(_ request: CreateThreadWithMessage, completion: @escaping CompletionType<Conversation>) {
        createThreadWithMessage(request, uniqueIdResult: nil, onSent: nil, onDelivery: nil, onSeen: nil, completion: completion)
    }

    /// Create thread and send a file message.
    /// - Parameters:
    ///   - request: Request of craete thread.
    ///   - textMessage: Text message.
    ///   - uploadFile: File request.
    func createThreadWithFileMessage(_ request: CreateThreadRequest, textMessage: SendTextMessageRequest, uploadFile: UploadFileRequest) {
        createThreadWithFileMessage(request,
                                    textMessage: textMessage,
                                    uploadFile: uploadFile,
                                    uploadProgress: nil,
                                    onSent: nil,
                                    onSeen: nil,
                                    onDeliver: nil,
                                    createThreadCompletion: nil,
                                    uploadUniqueIdResult: nil,
                                    messageUniqueIdResult: nil)
    }

    /// Deactivate assistants.
    /// - Parameters:
    ///   - request: A request that contains a list of activated assistants.
    ///   - completion: The result of deactivated assistants.
    func deactiveAssistant(_ request: DeactiveAssistantRequest, completion: @escaping CompletionType<[Assistant]>) {
        deactiveAssistant(request, completion: completion, uniqueIdResult: nil)
    }

    /// Delete a tag.
    /// - Parameters:
    ///   - request: The id of tag.
    ///   - completion: Response of the request if tag deleted successfully.
    func deleteTag(_ request: DeleteTagRequest, completion: @escaping CompletionType<Tag>) {
        deleteTag(request, completion: completion, uniqueIdResult: nil)
    }

    /// Delete a thread if you are admin in this thread.
    /// - Parameters:
    ///   - request: The request that contains thread id.
    ///   - completion: Result of request.
    func deleteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>) {
        deleteThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// Edit the tag name.
    /// - Parameters:
    ///   - request: The id of the tag and new name of the tag.
    ///   - completion: Response of the request if tag edited successfully.
    func editTag(_ request: EditTagRequest, completion: @escaping CompletionType<Tag>) {
        editTag(request, completion: completion, uniqueIdResult: nil)
    }

    /// Join to a public thread.
    /// - Parameters:
    ///   - request: Thread name of public thread.
    ///   - completion: Detail of public thread as a ``Conversation`` object.
    func joinThread(_ request: JoinPublicThreadRequest, completion: @escaping CompletionType<Conversation>) {
        joinThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// Leave a thread.
    /// - Parameters:
    ///   - request: The threadId if the thread with option to clear it's content.
    ///   - completion: The response of the left thread..
    func leaveThread(_ request: LeaveThreadRequest, completion: @escaping CompletionType<User>) {
        leaveThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// Mute a thread when a new event happens.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of mute thread.
    func muteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>) {
        muteThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// UNMute a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of unmute thread.
    func unmuteThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>) {
        unmuteThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// A list of mutual groups with a user.
    /// - Parameters:
    ///   - request: A request that contains a detail of a user invtee.
    ///   - completion: List of threads that are mutual between the current user and desired user.
    func mutualGroups(_ request: MutualGroupsRequest, completion: @escaping CompletionType<[Conversation]>, cacheResponse: CacheResponseType<[Conversation]>?) {
        mutualGroups(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// A list of mutual groups with a user.
    /// - Parameters:
    ///   - request: A request that contains a detail of a user invtee.
    ///   - completion: List of threads that are mutual between the current user and desired user.
    func mutualGroups(_ request: MutualGroupsRequest, completion: @escaping CompletionType<[Conversation]>) {
        mutualGroups(request, completion: completion, cacheResponse: nil, uniqueIdResult: nil)
    }

    /// Pin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of pin thread.
    func pinThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>) {
        pinThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// UNPin a thread.
    /// - Parameters:
    ///   - request: The request with a thread id.
    ///   - completion: Response of unpin thread.
    func unpinThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>) {
        unpinThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// Register a participant as an assistant.
    /// - Parameters:
    ///   - request: The request that contains list of assistants.
    ///   - completion: A list of assistant that added for the user.
    func registerAssistat(_ request: RegisterAssistantRequest, completion: @escaping CompletionType<[Assistant]>) {
        registerAssistat(request, completion: completion, uniqueIdResult: nil)
    }

    /// Remove participants from a thread.
    /// - Parameters:
    ///   - request: List of participants id and threadId.
    ///   - completion: Result of deleted participants.
    func removeParticipants(_ request: RemoveParticipantsRequest, completion: @escaping CompletionType<[Participant]>) {
        removeParticipants(request, completion: completion, uniqueIdResult: nil)
    }

    /// Remove tag participants from a tag.
    /// - Parameters:
    ///   - request: The tag id and the list of tag participants id.
    ///   - completion: List of removed tag participants.
    func removeTagParticipants(_ request: RemoveTagParticipantsRequest, completion: @escaping CompletionType<[TagParticipant]>) {
        removeTagParticipants(request, completion: completion, uniqueIdResult: nil)
    }

    /// Leave a thrad with replaceing admin.
    /// - Parameters:
    ///   - request: The request that contains threadId and participantId of new admin.
    ///   - completion: Result of request.
    ///   - newAdminCompletion: Result of new admin.
    func leaveThreadSaftly(_ request: SafeLeaveThreadRequest, completion: @escaping CompletionType<User>, newAdminCompletion: CompletionType<[UserRole]>?) {
        leaveThreadSaftly(request, completion: completion, newAdminCompletion: newAdminCompletion, uniqueIdResult: nil)
    }

    /// Mark a thread as an spam
    ///
    /// A spammed thread can't send a message anymore.
    /// - Parameters:
    ///   - request: Request to spam a thread.
    ///   - completion: Response of request.
    func spamPvThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Contact>) {
        spamPvThread(request, completion: completion, uniqueIdResult: nil)
    }

    /// List of Tags.
    /// - Parameters:
    ///   - uniqueId: The uniqueId of request if you want to set a specific one.
    ///   - completion: List of tags.
    ///   - cacheResponse: List of cached tags.
    func tagList(_ uniqueId: String? = nil, completion: @escaping CompletionType<[Tag]>, cacheResponse: CacheResponseType<[Tag]>?) {
        tagList(uniqueId, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Get the list of tag participants.
    /// - Parameters:
    ///   - request: The tag id.
    ///   - completion: List of tag participants.
    func getTagParticipants(_ request: GetTagParticipantsRequest, completion: @escaping CompletionType<[TagParticipant]>) {
        getTagParticipants(request, completion: completion, uniqueIdResult: nil)
    }

    /// Check name for the public thread is not occupied.
    /// - Parameters:
    ///   - request: The request for the name of the thread to check.
    ///   - completion: If thread name is free for using as public it will not be nil.
    func isThreadNamePublic(_ request: IsThreadNamePublicRequest, completion: @escaping CompletionType<PublicThreadNameAvailableResponse>) {
        isThreadNamePublic(request, completion: completion, uniqueIdResult: nil)
    }

    /// Get thread participants.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    ///   - completion: Pagination list of participants.
    ///   - cacheResponse: Cache response of participants inside a thread.
    func getThreadParticipants(_ request: ThreadParticipantsRequest, completion: @escaping CompletionType<[Participant]>, cacheResponse: CacheResponseType<[Participant]>?) {
        getThreadParticipants(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Get thread participants.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    ///   - completion: Pagination list of participants.
    func getThreadParticipants(_ request: ThreadParticipantsRequest, completion: @escaping CompletionType<[Participant]>) {
        getThreadParticipants(request, completion: completion, cacheResponse: nil, uniqueIdResult: nil)
    }

    /// Get thread participants.
    ///
    /// It's the same ``Chat/getThreadParticipants(_:completion:cacheResponse:uniqueIdResult:)`` only return admins.
    /// - Parameters:
    ///   - request: The request that contain threadId and count and offset.
    ///   - completion: Pagination list of participants.
    ///   - cacheResponse: Cache response of participants inside a thread.
    func getThreadAdmins(_ request: ThreadParticipantsRequest, completion: @escaping CompletionType<[Participant]>, cacheResponse: CacheResponseType<[Participant]>?) {
        getThreadAdmins(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Threads list that came from the cache?.
    func getThreads(_ request: ThreadsRequest, completion: @escaping CompletionType<[Conversation]>, cacheResponse: CacheResponseType<[Conversation]>?) {
        getThreads(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    ///   - completion: Response of list of threads that came with pagination.
    func getThreads(_ request: ThreadsRequest, completion: @escaping CompletionType<[Conversation]>) {
        getThreads(request, completion: completion, cacheResponse: nil, uniqueIdResult: nil)
    }

    /// Getting the all threads.
    /// - Parameters:
    ///   - request: If you send the summary true in request the result only contains list of all thread ids which is much faster way to fetch thread list.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Thread cache return data from disk so it contains all data in each model.
    func getAllThreads(_ request: AllThreads, completion: @escaping CompletionType<[Int]>, cacheResponse: CacheResponseType<[Int]>?, uniqueIdResult _: UniqueIdResultType?) {
        getAllThreads(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Threads list that came from the cache?.
    func getThreadsUnreadCount(_ request: ThreadsUnreadCountRequest, completion: @escaping CompletionType<[String: Int]>, cacheResponse: CacheResponseType<[String: Int]>?) {
        getThreadsUnreadCount(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    ///   - completion: Response of list of threads that came with pagination.
    func getThreadsUnreadCount(_ request: ThreadsUnreadCountRequest, completion: @escaping CompletionType<[String: Int]>) {
        getThreadsUnreadCount(request, completion: completion, cacheResponse: nil, uniqueIdResult: nil)
    }

    /// Update details of a thread.
    /// - Parameters:
    ///   - request: The request might contain an image, title, description, and a threadId.
    ///   - uploadProgress: Upload progrees if you update image of the thread.
    ///   - completion: Response of update.
    func updateThreadInfo(_ request: UpdateThreadInfoRequest, uploadProgress: @escaping UploadFileProgressType, completion: @escaping CompletionType<Conversation>) {
        updateThreadInfo(request, uniqueIdResult: nil, uploadProgress: uploadProgress, completion: completion)
    }
}
