//
// Chat+Message.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

// Request
extension Chat {
    func requestSendMessage(_ req: SendTextMessageRequest,
                            _ onSent: OnSentType?,
                            _ onSeen: OnSeenType?,
                            _ onDeliver: OnDeliveryType?,
                            _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: req,
                           uniqueIdResult: uniqueIdResult,
                           completion: nil as CompletionType<Voidcodable>?, //
                           onSent: onSent,
                           onDelivered: onDeliver,
                           onSeen: onSeen)
        cache.write(cacheType: .sendTxetMessageQueue(req))
        cache.save()
    }

    func requestForwardMessage(_ req: ForwardMessageRequest,
                               _ onSent: OnSentType? = nil,
                               _ onSeen: OnSeenType? = nil,
                               _ onDeliver: OnDeliveryType? = nil,
                               _ uniqueIdsResult: UniqueIdsResultType? = nil)
    {
        uniqueIdsResult?(req.uniqueIds) // do not remove this line it use batch uniqueIds
        prepareToSendAsync(req: req,
                           completion: nil as CompletionType<Voidcodable>?,
                           onSent: onSent,
                           onDelivered: onDeliver,
                           onSeen: onSeen)

        req.uniqueIds.forEach { uniqueId in
            callbacksManager.addCallback(uniqueId: uniqueId, requesType: .forwardMessage, callback: nil as CompletionType<Voidcodable>?, onSent: onSent, onDelivered: onDeliver, onSeen: onSeen)
        }
        cache.write(cacheType: .forwardMessageQueue(req))
        cache.save()
    }

    func requestSendLocationMessage(_ request: LocationMessageRequest,
                                    _ downloadProgress: DownloadProgressType? = nil,
                                    _ uploadProgress: UploadFileProgressType? = nil,
                                    _ onSent: OnSentType? = nil,
                                    _ onSeen: OnSeenType? = nil,
                                    _ onDeliver: OnDeliveryType? = nil,
                                    _ uploadUniqueIdResult: UniqueIdResultType? = nil,
                                    _ messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        let mapStaticReq = MapStaticImageRequest(center: request.mapCenter,
                                                 key: nil,
                                                 height: request.mapHeight,
                                                 width: request.mapWidth,
                                                 zoom: request.mapZoom,
                                                 type: request.mapType)

        requestDownloadMapStatic(mapStaticReq, downloadProgress) { [weak self] (response: ChatResponse<Data?>) in

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

    func requestMentions(_ req: MentionRequest,
                         _ completion: @escaping CompletionType<[Message]>,
                         _ cacheResponse: CacheResponseType<[Message]>? = nil,
                         _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Message]>) in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache.get(useCache: cacheResponse != nil, cacheType: .mentions) { (response: ChatResponse<[Message]>) in
            let predicate = NSPredicate(format: "threadId == %i", req.threadId)
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: CMMessage.crud.getTotalCount(predicate: predicate))
            cacheResponse?(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }

    func requestSendDeliverMessage(_ req: MessageDeliverRequest, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult)
    }

    func requestSendSeenMessage(_ req: MessageSeenRequest, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult)
        cache.write(cacheType: .lastThreadMessageSeen(req.threadId, req.messageId))
        cache.save()
    }
}

// Response
extension Chat {
    func onNewMessage(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8), let message = try? JSONDecoder().decode(Message.self, from: data) else { return }
        delegate?.chatEvent(event: .message(.messageNew(message)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        let unreadCount = message.conversation?.unreadCount ?? 0
        delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(threadId: chatMessage.subjectId ?? 0, count: unreadCount)))
        if message.threadId == nil {
            message.threadId = chatMessage.subjectId ?? message.conversation?.id
        }
        cache.write(cacheType: .message(message))

        // Check that we are not the sender of the message and message come from another person.
        if let messageId = message.id, message.participant?.id != userInfo?.id {
            deliver(.init(messageId: messageId))
        }
        if let threadId = message.threadId {
            cache.write(cacheType: .setThreadUnreadCount(threadId, message.conversation?.unreadCount ?? 0))
        }
        cache.save()
    }

    func onSentMessage(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        if let stringMessageId = chatMessage.content, let messageId = Int(stringMessageId), let threadId = chatMessage.subjectId {
            let sentResponse = MessageResponse(messageState: .sent, threadId: threadId, messageId: messageId, messageTime: UInt(chatMessage.time))
            delegate?.chatEvent(event: .message(.messageSent(sentResponse)))
            cache.write(cacheType: .messageSentToUser(sentResponse))
            cache.write(cacheType: .deleteQueue(chatMessage.uniqueId))
            cache.save()
            guard let callback = callbacksManager.getSentCallback(chatMessage.uniqueId) else { return }
            callback(sentResponse, chatMessage.uniqueId, nil)
            callbacksManager.removeSentCallback(uniqueId: chatMessage.uniqueId)
        }
    }

    func onDeliverMessage(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        if let data = chatMessage.content?.data(using: .utf8), let deliverResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
            deliverResponse.messageState = .delivered
            delegate?.chatEvent(event: .message(.messageDelivery(deliverResponse)))
            cache.write(cacheType: .messageDeliveredToUser(deliverResponse))
            cache.save()
            guard let callback = callbacksManager.getDeliverCallback(chatMessage.uniqueId) else { return }
            callback(deliverResponse, chatMessage.uniqueId, nil)
            callbacksManager.removeDeliverCallback(uniqueId: chatMessage.uniqueId)
        }
    }

    func onSeenMessage(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        if let data = chatMessage.content?.data(using: .utf8), let seenResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
            seenResponse.messageState = .seen
            delegate?.chatEvent(event: .message(.messageSeen(seenResponse)))
            cache.write(cacheType: .messageSeenByUser(seenResponse))
            cache.save()
            guard let callback = callbacksManager.getSeenCallback(chatMessage.uniqueId) else { return }
            callback(seenResponse, chatMessage.uniqueId, nil)
            callbacksManager.removeSeenCallback(uniqueId: chatMessage.uniqueId)
        }
    }

    func onLastMessageEdited(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let thread = try? JSONDecoder().decode(Conversation.self, from: data) else { return }
        delegate?.chatEvent(event: .thread(.lastMessageEdited(thread: thread)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        cache.write(cacheType: .threads([thread]))
        cache.save()
    }

    func onLastMessageDeleted(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let thread = try? JSONDecoder().decode(Conversation.self, from: data) else { return }
        delegate?.chatEvent(event: .thread(.lastMessageDeleted(thread: thread)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        if let threadId = thread.id, let lastMessage = thread.lastMessageVO {
            cache.write(cacheType: .lastThreadMessageUpdated(threadId, lastMessage))
            cache.save()
        }
    }
}
