//
// Chat+Message.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

// Request
public extension Chat {
    /// Send a plain text message to a thread.
    /// - Parameters:
    ///   - request: The request that contains text message and id of the thread.
    ///   - uniqueIdresult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func sendTextMessage(_ request: SendTextMessageRequest, uniqueIdResult: UniqueIdResultType? = nil, onSent: OnSentType? = nil, onSeen: OnSeenType? = nil, onDeliver: OnDeliveryType? = nil) {
        prepareToSendAsync(req: request,
                           uniqueIdResult: uniqueIdResult,
                           completion: nil as CompletionType<Voidcodable>?, //
                           onSent: onSent,
                           onDelivered: onDeliver,
                           onSeen: onSeen)
        cache?.conversation.updateLastMessage(request.threadId, request.textMessage)
        cache?.textQueue.insert(request)
    }

    /// Reply to a message.
    /// - Parameters:
    ///   - request: The request contains the id of the message you want to reply to, and id of the thread, and a text message.
    ///   - uniqueIdresult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    func replyMessage(_ request: ReplyMessageRequest, uniqueIdresult: UniqueIdResultType? = nil, onSent: OnSentType? = nil, onSeen: OnSeenType? = nil, onDeliver: OnDeliveryType? = nil) {
        sendTextMessage(request, uniqueIdResult: uniqueIdresult, onSent: onSent, onSeen: onSeen, onDeliver: onDeliver)
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

        mapStaticImage(mapStaticReq, downloadProgress) { [weak self] (response: ChatResponse<Data?>) in

            guard let data = response.result as? Data else { return }
            var hC = 0
            var wC = 0
            #if canImport(UIKit)
                let image = UIImage(data: data) ?? UIImage()
                hC = Int(image.size.height)
                wC = Int(image.size.width)
            #endif
            let imageRequest = UploadImageRequest(data: data,
                                                  hC: hC,
                                                  wC: wC,
                                                  fileExtension: ".png",
                                                  fileName: request.mapImageName,
                                                  mimeType: "image/png",
                                                  userGroupHash: request.userGroupHash,
                                                  uniqueId: request.uniqueId)
            imageRequest.typeCode = self?.config.typeCode

            let textMessage = SendTextMessageRequest(threadId: request.threadId,
                                                     textMessage: request.textMessage ?? "",
                                                     messageType: .podSpacePicture,
                                                     repliedTo: request.repliedTo,
                                                     systemMetadata: request.systemMetadata,
                                                     uniqueId: request.uniqueId)

            self?.sendFileMessage(textMessage: textMessage,
                                  uploadFile: imageRequest,
                                  uploadProgress: uploadProgress,
                                  onSent: onSent,
                                  onSeen: onSeen,
                                  onDeliver: onDeliver,
                                  uploadUniqueIdResult: uploadUniqueIdResult,
                                  messageUniqueIdResult: messageUniqueIdResult)
        }
    }

    /// Get messages that you have mentioned in a thread.
    /// - Parameters:
    ///   - request: The request that contains a threadId.
    ///   - completion: The response contains a list of messages that you have mentioned.
    ///   - cacheResponse: The cache response of mentioned messages inside a thread.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getMentions(_ request: MentionRequest, completion: @escaping CompletionType<[Message]>, cacheResponse: CacheResponseType<[Message]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Message]>) in
            let pagination = PaginationWithContentCount(count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache?.message.getMentions(request) { [weak self] messages, totalCount in
            let messages = messages.map { $0.codable() }
            self?.responseQueue.async {
                let pagination = PaginationWithContentCount(count: request.count, offset: request.offset, totalCount: totalCount)
                cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: messages, pagination: pagination))
            }
        }
    }

    /// Tell the sender of a message that the message is delivered successfully.
    /// - Parameters:
    ///   - request: The request that contains a messageId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    internal func deliver(_ request: MessageDeliverRequest, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult)
    }

    /// Send seen to participants of a thread that informs you have seen the message already.
    ///
    /// When you send seen the last seen messageId and unreadCount will be updated in cache behind the scene.
    /// - Parameters:
    ///   - request: The id of the message.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func seen(_ request: MessageSeenRequest, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult)
        cache?.message.seen(request)
        cache?.conversation.decreamentUnreadCount(request.threadId) { [weak self] unreadCount in
            self?.responseQueue.async {
                self?.delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(.init(result: .init(unreadCount: unreadCount, threadId: request.threadId)))))
            }
        }
    }
}

// Response
extension Chat {
    func onNewMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .message(.messageNew(response)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        guard let message = response.result else { return }
        if message.threadId == nil {
            message.threadId = response.subjectId ?? message.conversation?.id
        }
        cache?.message.insert(models: [message])
        // Check that we are not the sender of the message and message come from another person.
        // This means that the user himself was the sender of the message, therefore he saw messages inside the thread.
        let isMe = message.participant?.id == userInfo?.id
        if isMe {
            cache?.conversation.setUnreadCountToZero(response.subjectId ?? -1) { [weak self] unreadCount in
                self?.responseQueue.async {
                    let unreadCount = UnreadCount(unreadCount: unreadCount, threadId: response.subjectId)
                    self?.delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(.init(result: unreadCount))))
                }
            }
        } else {
            cache?.conversation.increamentUnreadCount(response.subjectId ?? -1) { [weak self] unreadCount in
                self?.responseQueue.async {
                    let unreadCount = UnreadCount(unreadCount: unreadCount, threadId: response.subjectId)
                    self?.delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(.init(result: unreadCount))))
                }
            }
        }
        deliver(.init(messageId: message.id ?? 0))
    }

    func onSentMessage(_ asyncMessage: AsyncMessage) {
        let response = asyncMessage.messageResponse(state: .sent)
        delegate?.chatEvent(event: .message(.messageSent(response)))
        deleteQueues(uniqueIds: [response.uniqueId ?? ""])
        callbacksManager.invokeSentCallbackAndRemove(response)
    }

    func onDeliverMessage(_ asyncMessage: AsyncMessage) {
        let response = asyncMessage.messageResponse(state: .delivered)
        delegate?.chatEvent(event: .message(.messageDelivery(response)))
        if let delivered = response.result {
            cache?.message.partnerDeliver(delivered)
        }
        deleteQueues(uniqueIds: [response.uniqueId ?? ""])
        callbacksManager.invokeDeliverCallbackAndRemove(response)
    }

    func onSeenMessage(_ asyncMessage: AsyncMessage) {
        let response = asyncMessage.messageResponse(state: .seen)
        if let seenResponse = response.result {
            delegate?.chatEvent(event: .message(.messageSeen(response)))
            cache?.message.partnerSeen(seenResponse)
            callbacksManager.invokeSeenCallbackAndRemove(response)
        }
    }

    func onLastMessageEdited(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.lastMessageEdited(response)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        if let thread = response.result {
            cache?.conversation.updateLastMessage(thread)
        }
    }

    func onLastMessageDeleted(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.lastMessageDeleted(response)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        if let thread = response.result {
            cache?.conversation.updateLastMessage(thread)
        }
    }
}
