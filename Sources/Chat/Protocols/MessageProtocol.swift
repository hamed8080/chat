//
// MessageProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

public protocol MessageProtocol {
    /// Get the number of unread message count.
    /// - Parameters:
    ///   - request: The request can contain property to aggregate mute threads unread count.
    ///   - completion: The number of unread message count.
    ///   - cacheResponse: The number of unread message count in cache?.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func allUnreadMessageCount(_ request: UnreadMessageCountRequest, completion: @escaping CompletionType<Int>, cacheResponse: CacheResponseType<Int>?, uniqueIdResult: UniqueIdResultType?)

    /// Cancel a message send.
    /// - Parameters:
    ///   - uniqueId: The uniqueId of a message to cancel and delete from cache.
    ///   - completion: The result of cancelation.
    func cancelMessage(uniqueId: String, completion: @escaping CompletionTypeNoneDecodeable<Bool>)

    /// Forwrad messages to a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId list and a destination threadId.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    ///   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func forwardMessages(_ request: ForwardMessageRequest, onSent: OnSentType?, onSeen: OnSeenType?, onDeliver: OnDeliveryType?, uniqueIdsResult: UniqueIdsResultType?)

    /// Clear all messages inside a thread for user.
    /// - Parameters:
    ///   - request: The request that  contains a threadId.
    ///   - completion: A threadId if the result was a success.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func clearHistory(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType?)

    /// Delete a message if it's ``Message/deletable``.
    /// - Parameters:
    ///   - request: The delete request with a messageId.
    ///   - completion: The response of deleted message.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deleteMessage(_ request: DeleteMessageRequest, completion: @escaping CompletionType<Message>, uniqueIdResult: UniqueIdResultType?)

    /// Delete multiple messages at once.
    /// - Parameters:
    ///   - request: The delete request with list of messagesId.
    ///   - completion: List of deleted messages.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deleteMultipleMessages(_ request: BatchDeleteMessageRequest, completion: @escaping CompletionType<Message>, uniqueIdResult: UniqueIdResultType?)

    /// Edit a message.
    /// - Parameters:
    ///   - request: The request that contains threadId and messageId and new text for the message you want to edit.
    ///   - completion: The result of edited message.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func editMessage(_ request: EditMessageRequest, completion: CompletionType<Message>?, uniqueIdResult: UniqueIdResultType?)

    /// Every time you call this function old export file for the thread will be deleted and replaced with a new one. To manages your storage be cautious about removing the file whenever you don't need this file.
    /// This function can only export 10000 messages.
    /// - Parameters:
    ///   - request: A request that contains threadId and other filters to export.
    ///   - localIdentifire: The locals to output.
    ///   - completion: A file url of a csv file.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func exportChat(_ request: GetHistoryRequest, completion: @escaping CompletionTypeNoneDecodeable<URL>, uniqueIdResult: UniqueIdResultType?)

    /// Get list of messages inside a thread.
    /// - Parameters:
    ///   - request: The threadId and other filter properties.
    ///   - completion: The response which can contains llist of messages.
    ///   - cacheResponse: The cache response.
    ///   - textMessageNotSentRequests: A list of messages that failed to sent.
    ///   - editMessageNotSentRequests: A list of edit messages that failed to sent.
    ///   - forwardMessageNotSentRequests: A list of forward messages that failed to sent.
    ///   - fileMessageNotSentRequests: A list of file messages that failed to sent.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getHistory(_ request: GetHistoryRequest,
                    completion: @escaping CompletionType<[Message]>,
                    cacheResponse: CacheResponseType<[Message]>?,
                    textMessageNotSentRequests: CompletionTypeNoneDecodeable<[SendTextMessageRequest]>?,
                    editMessageNotSentRequests: CompletionTypeNoneDecodeable<[EditMessageRequest]>?,
                    forwardMessageNotSentRequests: CompletionTypeNoneDecodeable<[ForwardMessageRequest]>?,
                    fileMessageNotSentRequests: CompletionTypeNoneDecodeable<[(UploadFileRequest, SendTextMessageRequest)]>?,
                    uniqueIdResult: UniqueIdResultType?)

    /// Send a plain text message to a thread.
    /// - Parameters:
    ///   - request: The request that contains text message and id of the thread.
    ///   - uniqueIdresult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func sendTextMessage(_ request: SendTextMessageRequest, uniqueIdResult: UniqueIdResultType?, onSent: OnSentType?, onSeen: OnSeenType?, onDeliver: OnDeliveryType?)

    /// Reply to a message.
    /// - Parameters:
    ///   - request: The request contains the id of the message you want to reply to, and id of the thread, and a text message.
    ///   - uniqueIdresult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func replyMessage(_ request: ReplyMessageRequest, uniqueIdresult: UniqueIdResultType?, onSent: OnSentType?, onSeen: OnSeenType?, onDeliver: OnDeliveryType?)

    /// Send a location.
    /// - Parameters:
    ///   - request: The request that gets a threadId and a location and a ``Conversation/userGroupHash``.
    ///   - uploadProgress: Progress of uploading an image of the location to the thread.
    ///   - downloadProgress: Download progess of image.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    ///   - uploadUniqueIdResult: Unique id of upload file you could cancel an upload if you need it.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func sendLocationMessage(_ request: LocationMessageRequest,
                             uploadProgress: UploadFileProgressType?,
                             downloadProgress: DownloadProgressType?,
                             onSent: OnSentType?,
                             onSeen: OnSeenType?,
                             onDeliver: OnDeliveryType?,
                             uploadUniqueIdResult: UniqueIdResultType?,
                             messageUniqueIdResult: UniqueIdResultType?)

    /// Get messages that you have mentioned in a thread.
    /// - Parameters:
    ///   - request: The request that contains a threadId.
    ///   - completion: The response contains a list of messages that you have mentioned.
    ///   - cacheResponse: The cache response of mentioned messages inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getMentions(_ request: MentionRequest, completion: @escaping CompletionType<[Message]>, cacheResponse: CacheResponseType<[Message]>?, uniqueIdResult: UniqueIdResultType?)

    /// Tell the sender of a message that the message is delivered successfully.
    /// - Parameters:
    ///   - request: The request that contains a messageId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deliver(_ request: MessageDeliverRequest, uniqueIdResult: UniqueIdResultType?)

    /// Send seen to participants of a thread that informs you have seen the message already.
    ///
    /// When you send seen the last seen messageId and unreadCount will be updated in cache behind the scene.
    /// - Parameters:
    ///   - request: The id of the message.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func seen(_ request: MessageSeenRequest, uniqueIdResult: UniqueIdResultType?)

    /// Retrieve the list of participants to who the message was delivered to them.
    /// - Parameters:
    ///   - request: The request that contains a message id.
    ///   - completion: List of participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func messageDeliveredToParticipants(_ request: MessageDeliveredUsersRequest, completion: @escaping CacheResponseType<[Participant]>, uniqueIdResult: UniqueIdResultType?)

    /// Retrieve the list of participants to who have seen the message.
    /// - Parameters:
    ///   - request: The request that contains a message id.
    ///   - completion: List of participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func messageSeenByUsers(_ request: MessageSeenByUsersRequest, completion: @escaping CacheResponseType<[Participant]>, uniqueIdResult: UniqueIdResultType?)

    /// Pin a message inside a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId.
    ///   - completion: The response of pinned thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func pinMessage(_ request: PinUnpinMessageRequest, completion: @escaping CompletionType<Message>, uniqueIdResult: UniqueIdResultType?)

    /// UnPin a message inside a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId.
    ///   - completion: The response of unpinned thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unpinMessage(_ request: PinUnpinMessageRequest, completion: @escaping CompletionType<Message>, uniqueIdResult: UniqueIdResultType?)
}

public extension MessageProtocol {
    /// Get the number of unread message count.
    /// - Parameters:
    ///   - request: The request can contain property to aggregate mute threads unread count.
    ///   - completion: The number of unread message count.
    ///   - cacheResponse: The number of unread message count in cache?.
    func allUnreadMessageCount(_ request: UnreadMessageCountRequest, completion: @escaping CompletionType<Int>, cacheResponse: CacheResponseType<Int>?) {
        allUnreadMessageCount(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Forwrad messages to a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId list and a destination threadId.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func forwardMessages(_ request: ForwardMessageRequest, onSent: OnSentType?, onSeen: OnSeenType?, onDeliver: OnDeliveryType?) {
        forwardMessages(request, onSent: onSent, onSeen: onSeen, onDeliver: onDeliver, uniqueIdsResult: nil)
    }

    /// Clear all messages inside a thread for user.
    /// - Parameters:
    ///   - request: The request that  contains a threadId.
    ///   - completion: A threadId if the result was a success.
    func clearHistory(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>) {
        clearHistory(request, completion: completion, uniqueIdResult: nil)
    }

    /// Delete a message if it's ``Message/deletable``.
    /// - Parameters:
    ///   - request: The delete request with a messageId.
    ///   - completion: The response of deleted message.
    func deleteMessage(_ request: DeleteMessageRequest, completion: @escaping CompletionType<Message>) {
        deleteMessage(request, completion: completion, uniqueIdResult: nil)
    }

    /// Delete multiple messages at once.
    /// - Parameters:
    ///   - request: The delete request with list of messagesId.
    ///   - completion: List of deleted messages.
    func deleteMultipleMessages(_ request: BatchDeleteMessageRequest, completion: @escaping CompletionType<Message>) {
        deleteMultipleMessages(request, completion: completion, uniqueIdResult: nil)
    }

    /// Edit a message.
    /// - Parameters:
    ///   - request: The request that contains threadId and messageId and new text for the message you want to edit.
    ///   - completion: The result of edited message.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, , you must use it if you need to know what response is for what request.
    func editMessage(_ request: EditMessageRequest, completion: CompletionType<Message>?) {
        editMessage(request, completion: completion, uniqueIdResult: nil)
    }

    /// Every time you call this function old export file for the thread will be deleted and replaced with a new one. To manages your storage be cautious about removing the file whenever you don't need this file.
    /// This function can only export 10000 messages.
    /// - Parameters:
    ///   - request: A request that contains threadId and other filters to export.
    ///   - localIdentifire: The locals to output.
    ///   - completion: A file url of a csv file.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func exportChat(_ request: GetHistoryRequest, completion: @escaping CompletionTypeNoneDecodeable<URL>) {
        exportChat(request, completion: completion, uniqueIdResult: nil)
    }

    /// Get list of messages inside a thread.
    /// - Parameters:
    ///   - request: The threadId and other filter properties.
    ///   - completion: The response which can contains llist of messages.
    ///   - cacheResponse: The cache response.
    ///   - textMessageNotSentRequests: A list of messages that failed to sent.
    ///   - editMessageNotSentRequests: A list of edit messages that failed to sent.
    ///   - forwardMessageNotSentRequests: A list of forward messages that failed to sent.
    ///   - fileMessageNotSentRequests: A list of file messages that failed to sent.
    func getHistory(_ request: GetHistoryRequest,
                    completion: @escaping CompletionType<[Message]>,
                    cacheResponse: CacheResponseType<[Message]>?,
                    textMessageNotSentRequests: CompletionTypeNoneDecodeable<[SendTextMessageRequest]>?,
                    editMessageNotSentRequests: CompletionTypeNoneDecodeable<[EditMessageRequest]>?,
                    forwardMessageNotSentRequests: CompletionTypeNoneDecodeable<[ForwardMessageRequest]>?,
                    fileMessageNotSentRequests: CompletionTypeNoneDecodeable<[(UploadFileRequest, SendTextMessageRequest)]>?)
    {
        getHistory(request,
                   completion: completion,
                   cacheResponse: cacheResponse,
                   textMessageNotSentRequests: textMessageNotSentRequests,
                   editMessageNotSentRequests: editMessageNotSentRequests,
                   forwardMessageNotSentRequests: forwardMessageNotSentRequests,
                   fileMessageNotSentRequests: fileMessageNotSentRequests,
                   uniqueIdResult: nil)
    }

    /// Get list of messages inside a thread.
    /// - Parameters:
    ///   - request: The threadId and other filter properties.
    ///   - completion: The response which can contains llist of messages.
    ///   - cacheResponse: The cache response.
    func getHistory(_ request: GetHistoryRequest, completion: @escaping CompletionType<[Message]>, cacheResponse: CacheResponseType<[Message]>?) {
        getHistory(request,
                   completion: completion,
                   cacheResponse: cacheResponse,
                   textMessageNotSentRequests: nil,
                   editMessageNotSentRequests: nil,
                   forwardMessageNotSentRequests: nil,
                   fileMessageNotSentRequests: nil,
                   uniqueIdResult: nil)
    }

    /// Send a plain text message to a thread.
    /// - Parameters:
    ///   - request: The request that contains text message and id of the thread.
    ///   - uniqueIdresult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func sendTextMessage(_ request: SendTextMessageRequest, onSent: OnSentType?, onSeen: OnSeenType?, onDeliver: OnDeliveryType?) {
        sendTextMessage(request, uniqueIdResult: nil, onSent: onSent, onSeen: onSeen, onDeliver: onDeliver)
    }

    /// Reply to a message.
    /// - Parameters:
    ///   - request: The request contains the id of the message you want to reply to, and id of the thread, and a text message.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func replyMessage(_ request: ReplyMessageRequest, onSent: OnSentType?, onSeen: OnSeenType?, onDeliver: OnDeliveryType?) {
        replyMessage(request, uniqueIdresult: nil, onSent: onSent, onSeen: onSeen, onDeliver: onDeliver)
    }

    /// Send a location.
    /// - Parameters:
    ///   - request: The request that gets a threadId and a location and a ``Conversation/userGroupHash``.
    ///   - uploadProgress: Progress of uploading an image of the location to the thread.
    ///   - downloadProgress: Download progess of image.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func sendLocationMessage(_ request: LocationMessageRequest,
                             uploadProgress: UploadFileProgressType?,
                             downloadProgress: DownloadProgressType?,
                             onSent: OnSentType?,
                             onSeen: OnSeenType?,
                             onDeliver: OnDeliveryType?)
    {
        sendLocationMessage(request,
                            uploadProgress: uploadProgress,
                            downloadProgress: downloadProgress,
                            onSent: onSent,
                            onSeen: onSeen,
                            onDeliver: onDeliver,
                            uploadUniqueIdResult: nil,
                            messageUniqueIdResult: nil)
    }

    /// Get messages that you have mentioned in a thread.
    /// - Parameters:
    ///   - request: The request that contains a threadId.
    ///   - completion: The response contains a list of messages that you have mentioned.
    ///   - cacheResponse: The cache response of mentioned messages inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getMentions(_ request: MentionRequest, completion: @escaping CompletionType<[Message]>, cacheResponse: CacheResponseType<[Message]>?) {
        getMentions(request, completion: completion, cacheResponse: cacheResponse, uniqueIdResult: nil)
    }

    /// Tell the sender of a message that the message is delivered successfully.
    /// - Parameters:
    ///   - request: The request that contains a messageId.
    func deliver(_ request: MessageDeliverRequest) {
        deliver(request, uniqueIdResult: nil)
    }

    /// Send seen to participants of a thread that informs you have seen the message already.
    ///
    /// When you send seen the last seen messageId and unreadCount will be updated in cache behind the scene.
    /// - Parameters:
    ///   - request: The id of the message.
    func seen(_ request: MessageSeenRequest) {
        seen(request, uniqueIdResult: nil)
    }

    /// Retrieve the list of participants to who the message was delivered to them.
    /// - Parameters:
    ///   - request: The request that contains a message id.
    ///   - completion: List of participants.
    func messageDeliveredToParticipants(_ request: MessageDeliveredUsersRequest, completion: @escaping CacheResponseType<[Participant]>) {
        messageDeliveredToParticipants(request, completion: completion, uniqueIdResult: nil)
    }

    /// Retrieve the list of participants to who have seen the message.
    /// - Parameters:
    ///   - request: The request that contains a message id.
    ///   - completion: List of participants.
    func messageSeenByUsers(_ request: MessageSeenByUsersRequest, completion: @escaping CacheResponseType<[Participant]>) {
        messageSeenByUsers(request, completion: completion, uniqueIdResult: nil)
    }

    /// Pin a message inside a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId.
    ///   - completion: The response of pinned thread.
    func pinMessage(_ request: PinUnpinMessageRequest, completion: @escaping CompletionType<Message>) {
        pinMessage(request, completion: completion, uniqueIdResult: nil)
    }

    /// UnPin a message inside a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId.
    ///   - completion: The response of unpinned thread.
    func unpinMessage(_ request: PinUnpinMessageRequest, completion: @escaping CompletionType<Message>) {
        unpinMessage(request, completion: completion, uniqueIdResult: nil)
    }
}
