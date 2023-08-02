//
// MessageProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels
import Foundation

public protocol MessageProtocol {
    /// Cancel a message send.
    /// - Parameters:
    ///   - uniqueId: The uniqueId of a message to cancel and delete from cache.
    func cancel(uniqueId: String)

    /// Forwrad messages to a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId list and a destination threadId.
    func send(_ request: ForwardMessageRequest)

    /// Clear all messages inside a thread for user.
    /// - Parameters:
    ///   - request: The request that  contains a threadId.
    func clear(_ request: GeneralSubjectIdRequest)

    /// Delete a message if it's ``Message/deletable``.
    /// - Parameters:
    ///   - request: The delete request with a messageId.
    func delete(_ request: DeleteMessageRequest)

    /// Delete multiple messages at once.
    /// - Parameters:
    ///   - request: The delete request with list of messagesId.
    func delete(_ request: BatchDeleteMessageRequest)

    /// Edit a message.
    /// - Parameters:
    ///   - request: The request that contains threadId and messageId and new text for the message you want to edit.
    func edit(_ request: EditMessageRequest)

    /// Every time you call this function old export file for the thread will be deleted and replaced with a new one. To manages your storage be cautious about removing the file whenever you don't need this file.
    /// This function can only export 10000 messages.
    /// - Parameters:
    ///   - request: A request that contains threadId and other filters to export.
    func export(_ request: GetHistoryRequest)

    /// Get list of messages inside a thread.
    /// - Parameters:
    ///   - request: The threadId and other filter properties.
    func history(_ request: GetHistoryRequest)

    /// Send a plain text message to a thread.
    /// - Parameters:
    ///   - request: The request that contains text message and id of the thread.
    func send(_ request: SendTextMessageRequest)

    /// Send a location.
    /// - Parameters:
    ///   - request: The request that gets a threadId and a location and a ``Conversation/userGroupHash``.
    func send(_ request: LocationMessageRequest)

    /// Send a file message.
    /// - Parameters:
    ///   - textMessage: A text message with a threadId.
    ///   - fileRequest: The request that contains the data of a file and other file properties.
    func send(_ textMessage: SendTextMessageRequest, _ fileRequest: UploadFileRequest)

    /// Send a file message.
    /// - Parameters:
    ///   - textMessage: A text message with a threadId.
    ///   - imageRequest: The request that contains the data of an image and other image properties.
    func send(_ textMessage: SendTextMessageRequest, _ imageRequest: UploadImageRequest)

    /// Reply to a message.
    /// - Parameters:
    ///   - request: The request contains the id of the message you want to reply to, and id of the thread, and a text message.
    func reply(_ request: ReplyMessageRequest)

    /// Privately reply to a participant who is the same thread is you with a message.
    /// - Parameters:
    ///   - request: The request contains the id of the message you want to reply to, and id of the thread, and a text message.
    func replyPrivately(_ request: ReplyPrivatelyRequest)

    /// Reply to a mesaage inside a thread with a file.
    /// - Parameters:
    ///   - replyMessage: The request that contains the threadId and a text message an id of an message you want to reply.
    ///   - fileRequest: The request that contains the data of a file and other file properties.
    func reply(_ replyMessage: ReplyMessageRequest, _ fileRequest: UploadFileRequest)

    /// Reply to a mesaage inside a thread with a file.
    /// - Parameters:
    ///   - replyMessage: The request that contains the threadId and a text message an id of an message you want to reply.
    ///   - imageRequest: The request that contains the data of an image and other image properties.
    func reply(_ replyMessage: ReplyMessageRequest, _ imageRequest: UploadImageRequest)

    /// Get messages that you have mentioned in a thread.
    /// - Parameters:
    ///   - request: The request that contains a threadId.
    func mentions(_ request: MentionRequest)

    /// Tell the sender of a message that the message is delivered successfully.
    /// - Parameters:
    ///   - request: The request that contains a messageId.
    func deliver(_ request: MessageDeliverRequest)

    /// Send seen to participants of a thread that informs you have seen the message already.
    ///
    /// When you send seen the last seen messageId and unreadCount will be updated in cache behind the scene.
    /// - Parameters:
    ///   - request: The id of the message.
    func seen(_ request: MessageSeenRequest)

    /// Retrieve the list of participants to who the message was delivered to them.
    /// - Parameters:
    ///   - request: The request that contains a message id.
    func deliveredToParricipants(_ request: MessageDeliveredUsersRequest)

    /// Retrieve the list of participants to who have seen the message.
    /// - Parameters
    ///   - request: The request that contains a message id.
    func seenByParticipants(_ request: MessageSeenByUsersRequest)

    /// Pin a message inside a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId.
    func pin(_ request: PinUnpinMessageRequest)

    /// UnPin a message inside a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId.
    func unpin(_ request: PinUnpinMessageRequest)
}
