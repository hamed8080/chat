//
// ChatImplementation+Message.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

// Request
public extension ChatImplementation {
    /// Send a plain text message to a thread.
    /// - Parameters:
    ///   - request: The request that contains text message and id of the thread.
    ///   - uniqueIdresult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func sendTextMessage(_ request: SendTextMessageRequest, uniqueIdResult: UniqueIdResultType? = nil, onSent: OnSentType? = nil, onSeen: OnSeenType? = nil, onDeliver: OnDeliveryType? = nil) {
        prepareToSendAsync(req: request,
                           type: .message,
                           uniqueIdResult: uniqueIdResult,
                           completion: nil as CompletionType<Voidcodable>?,
                           onSent: onSent,
                           onDelivered: onDeliver,
                           onSeen: onSeen)
        let lastMessageVO = Message(threadId: request.threadId, message: request.textMessage, uniqueId: request.uniqueId)
        try? cache?.conversation?.replaceLastMessage(.init(id: request.threadId, lastMessage: lastMessageVO.message, lastMessageVO: lastMessageVO))
        cache?.textQueue?.insert(models: [request.queueOfTextMessages])
    }

    /// Reply to a message.
    /// - Parameters:
    ///   - request: The request contains the id of the message you want to reply to, and id of the thread, and a text message.
    ///   - uniqueIdresult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func replyMessage(_ request: ReplyMessageRequest, uniqueIdresult: UniqueIdResultType? = nil, onSent: OnSentType? = nil, onSeen: OnSeenType? = nil, onDeliver: OnDeliveryType? = nil) {
        sendTextMessage(request.sendTextMessageRequest, uniqueIdResult: uniqueIdresult, onSent: onSent, onSeen: onSeen, onDeliver: onDeliver)
    }

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
                             uploadProgress: UploadFileProgressType? = nil,
                             downloadProgress: DownloadProgressType? = nil,
                             onSent: OnSentType? = nil,
                             onSeen: OnSeenType? = nil,
                             onDeliver: OnDeliveryType? = nil,
                             uploadUniqueIdResult: UniqueIdResultType? = nil,
                             messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        let mapStaticReq = MapStaticImageRequest(center: request.mapCenter,
                                                 key: nil,
                                                 height: request.mapHeight,
                                                 width: request.mapWidth,
                                                 zoom: request.mapZoom,
                                                 type: request.mapType)

        mapStaticImage(mapStaticReq, downloadProgress: downloadProgress) { [weak self] (response: ChatResponse<Data?>) in
            guard let self = self, let data = response.result as? Data else { return }
            var hC = 0
            var wC = 0
            #if canImport(UIKit)
                let image = UIImage(data: data) ?? UIImage()
                hC = Int(image.size.height)
                wC = Int(image.size.width)
            #endif
            let imageRequest = UploadImageRequest(data: data,
                                                  fileExtension: ".png",
                                                  fileName: request.mapImageName ?? "",
                                                  mimeType: "image/png",
                                                  userGroupHash: request.userGroupHash,
                                                  uniqueId: request.uniqueId,
                                                  hC: hC,
                                                  wC: wC)
            var textMessageReq = SendTextMessageRequest(threadId: request.threadId,
                                                        textMessage: request.textMessage ?? "",
                                                        messageType: .location,
                                                        repliedTo: request.repliedTo,
                                                        systemMetadata: request.systemMetadata,
                                                        uniqueId: request.uniqueId)

            self.cache?.fileQueue?.insert(models: [textMessageReq.queueOfFileMessages(imageRequest)])
            messageUniqueIdResult?(textMessageReq.chatUniqueId)
            self.uploadImage(imageRequest, uploadUniqueIdResult: uploadUniqueIdResult, uploadProgress: uploadProgress) { [weak self] _, fileMetaData, error in
                // completed upload file
                if let error = error {
                    self?.delegate?.chatError(error: error)
                } else {
                    fileMetaData?.latitude = request.mapCenter.lat
                    fileMetaData?.longitude = request.mapCenter.lng
                    guard let stringMetaData = fileMetaData.jsonString else { return }
                    textMessageReq.metadata = stringMetaData
                    self?.sendTextMessage(textMessageReq,
                                          uniqueIdResult: messageUniqueIdResult,
                                          onSent: onSent,
                                          onSeen: onSeen,
                                          onDeliver: onDeliver)
                }
            }
        }
    }

    /// Get messages that you have mentioned in a thread.
    /// - Parameters:
    ///   - request: The request that contains a threadId.
    ///   - completion: The response contains a list of messages that you have mentioned.
    ///   - cacheResponse: The cache response of mentioned messages inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getMentions(_ request: MentionRequest, completion: @escaping CompletionType<[Message]>, cacheResponse: CacheResponseType<[Message]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .getHistory, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Message]>) in
            let pagination = PaginationWithContentCount(hasNext: response.result?.count ?? 0 >= request.count, count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache?.message?.getMentions(threadId: request.threadId, offset: request.offset, count: request.count) { [weak self] messages, totalCount in
            let messages = messages.map { $0.codable() }
            self?.responseQueue.async {
                let pagination = PaginationWithContentCount(hasNext: messages.count >= request.count, count: request.count, offset: request.offset, totalCount: totalCount)
                cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: messages, pagination: pagination))
            }
        }
    }

    /// Tell the sender of a message that the message is delivered successfully.
    /// - Parameters:
    ///   - request: The request that contains a messageId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deliver(_ request: MessageDeliverRequest, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .delivery, uniqueIdResult: uniqueIdResult)
    }

    /// Send seen to participants of a thread that informs you have seen the message already.
    ///
    /// When you send seen the last seen messageId and unreadCount will be updated in cache behind the scene.
    /// - Parameters:
    ///   - request: The id of the message.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func seen(_ request: MessageSeenRequest, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .seen, uniqueIdResult: uniqueIdResult)
        cache?.message?.seen(threadId: request.threadId, messageId: request.messageId, mineUserId: userInfo?.id ?? -1)
        cache?.conversation?.setUnreadCount(action: .decrease, threadId: request.threadId) { [weak self] unreadCount in
            self?.responseQueue.async {
                self?.delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(.init(result: .init(unreadCount: unreadCount, threadId: request.threadId)))))
            }
        }
    }
}

// Response
extension ChatImplementation {
    func onNewMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .message(.messageNew(response)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        guard let message = response.result else { return }
        if message.threadId == nil {
            message.threadId = response.subjectId ?? message.conversation?.id
        }
        /// If we were sender of the message therfore we have seen all the messages inside the thread.
        let isMe = message.participant?.id == userInfo?.id
        let unreadCountAction: CacheUnreadCountAction = isMe ? .set(0) : .increase
        cache?.conversation?.setUnreadCount(action: unreadCountAction, threadId: response.subjectId ?? -1) { [weak self] unreadCount in
            self?.responseQueue.async {
                let unreadCount = UnreadCount(unreadCount: unreadCount, threadId: response.subjectId)
                self?.delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(.init(result: unreadCount))))
            }
        }
        /// It will insert a new message into the Message table if the sender is not me
        /// and it will update a current message with a uniqueId of a message when we were the sender of a message, and consequently, it will set lastMessageVO for the thread.
        try? cache?.conversation?.replaceLastMessage(.init(id: message.threadId, lastMessage: message.message, lastMessageVO: message))
        if !isMe {
            deliver(.init(messageId: message.id ?? 0, threadId: message.threadId))
        }
    }

    func onSentMessage(_ asyncMessage: AsyncMessage) {
        guard let response = asyncMessage.messageResponse(state: .sent) else { return }
        delegate?.chatEvent(event: .message(.messageSent(response)))
        cache?.deleteQueues(uniqueIds: [response.uniqueId ?? ""])
        callbacksManager.invokeSentCallbackAndRemove(response)
    }

    func onDeliverMessage(_ asyncMessage: AsyncMessage) {
        guard let response = asyncMessage.messageResponse(state: .delivered) else { return }
        delegate?.chatEvent(event: .message(.messageDelivery(response)))
        if let delivered = response.result {
            cache?.message?.partnerDeliver(threadId: delivered.threadId ?? -1, messageId: delivered.messageId ?? -1, messageTime: delivered.messageTime ?? 0)
        }
        cache?.deleteQueues(uniqueIds: [response.uniqueId ?? ""])
        callbacksManager.invokeDeliverCallbackAndRemove(response)
    }

    func onSeenMessage(_ asyncMessage: AsyncMessage) {
        guard let response = asyncMessage.messageResponse(state: .seen) else { return }
        if let seenResponse = response.result {
            delegate?.chatEvent(event: .message(.messageSeen(response)))
            cache?.message?.partnerSeen(threadId: seenResponse.threadId ?? -1, messageId: seenResponse.messageId ?? -1, mineUserId: userInfo?.id ?? -1)
            callbacksManager.invokeSeenCallbackAndRemove(response)
        }
    }

    func onLastMessageEdited(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.lastMessageEdited(response)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        if let thread = response.result {
            try? cache?.conversation?.replaceLastMessage(thread)
        }
    }

    func onLastMessageDeleted(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.lastMessageDeleted(response)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        if let thread = response.result {
            let lastMessageVO = Message(threadId: thread.id, message: thread.lastMessage)
            try? cache?.conversation?.replaceLastMessage(.init(id: lastMessageVO.threadId, lastMessage: lastMessageVO.message, lastMessageVO: lastMessageVO))
        }
    }
}
