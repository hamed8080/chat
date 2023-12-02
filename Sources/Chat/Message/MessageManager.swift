//
// MessageManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

final class MessageManager: MessageProtocol {
    let chat: ChatInternalProtocol
    var delegate: ChatDelegate? { chat.delegate }
    var cache: CacheManager? { chat.cache }
    var exportVM: ExportMessagesProtocol?

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func cancel(uniqueId: String) {
        cache?.deleteQueues(uniqueIds: [uniqueId])
        chat.file.manageUpload(uniqueId: uniqueId, action: .cancel)
    }

    func clear(_ request: GeneralSubjectIdRequest) {
        chat.prepareToSendAsync(req: request, type: .clearHistory)
    }

    func onClearHistory(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        cache?.message?.clearHistory(threadId: response.result ?? -1)
        delegate?.chatEvent(event: .message(.cleared(response)))
    }

    func delete(_ request: DeleteMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .deleteMessage)
    }

    func delete(_ request: BatchDeleteMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .deleteMessage)
    }

    func onDeleteMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .message(.deleted(response)))
        delegate?.chatEvent(event: .thread(.activity(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        cache?.message?.find(response.subjectId ?? -1, response.result?.id ?? -1) { [weak self] entity in
            if entity?.seen == nil, entity?.ownerId?.intValue != self?.chat.userInfo?.id {
                self?.cache?.conversation?.setUnreadCount(action: .decrease, threadId: response.subjectId ?? -1) { [weak self] unreadCount in
                    self?.delegate?.chatEvent(event: .thread(.updatedUnreadCount(.init(result: .init(unreadCount: unreadCount, threadId: response.subjectId)))))
                }
            }
        }
        cache?.message?.delete(response.subjectId ?? -1, response.result?.id ?? -1)
    }

    func edit(_ request: EditMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .editMessage)
        cache?.editQueue?.insert(models: [request.queueOfTextMessages])
    }

    func onEditMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .message(.edited(response)))
        delegate?.chatEvent(event: .thread(.activity(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        if let message = response.result {
            cache?.deleteQueues(uniqueIds: [response.uniqueId ?? ""])
            try? cache?.conversation?.replaceLastMessage(.init(id: response.subjectId, lastMessage: message.message, lastMessageVO: message))
        }
    }

    func export(_ request: GetHistoryRequest) {
        guard let chat = chat as? ChatImplementation else { return }
        exportVM = ExportMessages(chat: chat, request: request)
        exportVM?.start()
    }

    func onExportMessages(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Message]> = asyncMessage.toChatResponse()
        exportVM?.onReceive(response)
    }

    func history(_ request: GetHistoryRequest) {
        chat.prepareToSendAsync(req: request, type: .getHistory)
        cache?.message?.fetch(request.fetchRequest) { [weak self] messages, totalCount in
            let messages = messages.map { $0.codable(fillConversation: false) }
            let hasNext = totalCount >= request.count
            let response = ChatResponse(uniqueId: request.uniqueId, result: messages, contentCount: totalCount, hasNext: hasNext, cache: true)
            self?.chat.delegate?.chatEvent(event: .message(.history(response)))
        }
    }

    func unsentTextMessages(_ request: GetHistoryRequest) {
        cache?.textQueue?.unsendForThread(request.threadId, request.count, request.offset) { [weak self] unsedTexts, _ in
            let requests = unsedTexts.map(\.codable.request)
            let response = ChatResponse(uniqueId: request.uniqueId, result: requests, cache: true)
            self?.chat.delegate?.chatEvent(event: .message(.queueTextMessages(response)))
        }
    }

    func unsentEditMessages(_ request: GetHistoryRequest) {
        cache?.editQueue?.unsendForThread(request.threadId, request.count, request.offset) { [weak self] unsendEdits, _ in
            let requests = unsendEdits.map(\.codable.request)
            let response = ChatResponse(uniqueId: request.uniqueId, result: requests, cache: true)
            self?.chat.delegate?.chatEvent(event: .message(.queueEditMessages(response)))
        }
    }

    func unsentForwardMessages(_ request: GetHistoryRequest) {
        cache?.forwardQueue?.unsendForThread(request.threadId, request.count, 100) { [weak self] unsendForwards, _ in
            let requests = unsendForwards.map(\.codable.request)
            let response = ChatResponse(uniqueId: request.uniqueId, result: requests, cache: true)
            self?.chat.delegate?.chatEvent(event: .message(.queueForwardMessages(response)))
        }
    }

    func unsentFileMessages(_ request: GetHistoryRequest) {
        cache?.fileQueue?.unsendForThread(request.threadId, request.count, request.offset) { [weak self] unsendFiles, _ in
            let requests = unsendFiles.map(\.codable.request)
            let response = ChatResponse(uniqueId: request.uniqueId, result: requests, cache: true)
            self?.chat.delegate?.chatEvent(event: .message(.queueFileMessages(response)))
        }
    }

    func getHashtagList(_ request: GetHistoryRequest) {
        history(request)
    }

    func saveMessagesToCache(_ messages: [Message]?, _ threadId: Int) {
        cache?.message?.insert(models: messages ?? [], threadId: threadId)
        let uniqueIds = messages?.compactMap(\.uniqueId) ?? []
        cache?.deleteQueues(uniqueIds: uniqueIds)
    }

    func onGetHistroy(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Message]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        delegate?.chatEvent(event: .message(.history(response)))
        cache?.message?.insert(models: response.result ?? [], threadId: response.subjectId ?? -1)
    }

    func send(_ request: ForwardMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .forwardMessage)
        cache?.forwardQueue?.insert(models: [request.queueOfForwardMessages])
    }

    func send(_ request: SendTextMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .message)
        let lastMessageVO = Message(threadId: request.threadId, message: request.textMessage, uniqueId: request.uniqueId)
        try? cache?.conversation?.replaceLastMessage(.init(id: request.threadId, lastMessage: lastMessageVO.message, lastMessageVO: lastMessageVO))
        cache?.textQueue?.insert(models: [request.queueOfTextMessages])
    }

    func send(_ request: LocationMessageRequest) {
        let mapStaticReq = MapStaticImageRequest(center: request.mapCenter,
                                                 key: nil,
                                                 height: request.mapHeight,
                                                 width: request.mapWidth,
                                                 zoom: request.mapZoom,
                                                 type: request.mapType)

        (chat.map as? InternalMapProtocol)?.image(mapStaticReq) { [weak self] response in
            guard let self = self, let data = response.result else { return }
            var hC = 0
            var wC = 0
            #if canImport(UIKit)
                let image = UIImage(data: data) ?? UIImage()
                hC = Int(image.size.height)
                wC = Int(image.size.width)
            #endif
            /// Convert and set uniqueId request
            let imageRequest = request.imageRequest(data: data, wC: wC, hC: hC)
            var textMessageReq = request.textMessageRequest

            (chat.map as? InternalMapProtocol)?.reverse(.init(lat: request.mapCenter.lat, lng: request.mapCenter.lng)) { [weak self] response in
                if let reverse = response.result {
                    self?.sendTextLoactionMessage(request.mapCenter, textMessageReq, imageRequest, reverse)
                }
            }
        }
    }

    private func sendTextLoactionMessage(_ coordinate: Coordinate, _ textMessageReq: SendTextMessageRequest, _ imageRequest: UploadImageRequest, _ reverse: MapReverse) {
        cache?.fileQueue?.insert(models: [textMessageReq.queueOfFileMessages(imageRequest)])
        (chat.file as? ChatFileManager)?.upload(imageRequest, nil) { [weak self] imageResponse, fileMetaData, error in
            var metaData = fileMetaData
            metaData?.latitude = coordinate.lat
            metaData?.longitude = coordinate.lng
            metaData?.reverse = reverse.string
            self?.sendTextMessageOnUploadCompletion(textMessageReq, imageRequest.uniqueId, imageResponse, metaData, error)
        }
    }

    func reply(_ request: ReplyMessageRequest) {
        send(request.textMessageRequest)
    }

    func send(_ textMessage: SendTextMessageRequest, _ imageRequest: UploadImageRequest) {
        var textMessage = imageRequest.textMessageRequest(textMessage: textMessage)
        cache?.fileQueue?.insert(models: [textMessage.queueOfFileMessages(imageRequest)])
        (chat.file as? ChatFileManager)?.upload(imageRequest, nil) { [weak self] imageResponse, fileMetaData, error in
            self?.sendTextMessageOnUploadCompletion(textMessage, imageRequest.uniqueId, imageResponse, fileMetaData, error)
        }
    }

    func send(_ textMessage: SendTextMessageRequest, _ fileRequest: UploadFileRequest) {
        var textMessage = fileRequest.textMessageRequest(textMessage: textMessage)
        cache?.fileQueue?.insert(models: [textMessage.queueOfFileMessages(fileRequest)])
        (chat.file as? ChatFileManager)?.upload(fileRequest, nil) { [weak self] fileResponse, fileMetaData, error in
            self?.sendTextMessageOnUploadCompletion(textMessage, fileRequest.uniqueId, fileResponse, fileMetaData, error)
        }
    }

    func reply(_ replyMessage: ReplyMessageRequest, _ fileRequest: UploadFileRequest) {
        send(replyMessage.textMessageRequest, fileRequest)
    }

    func reply(_ replyMessage: ReplyMessageRequest, _ imageRequest: UploadImageRequest) {
        send(replyMessage.textMessageRequest, imageRequest)
    }

    private func sendTextMessageOnUploadCompletion(_ textMessage: SendTextMessageRequest, _ uniqueId: String, _: UploadFileResponse?, _ metadata: FileMetaData?, _ error: ChatError?) {
        if let error = error {
            let response = ChatResponse(uniqueId: uniqueId, result: Any?.none, error: error)
            chat.delegate?.chatEvent(event: .system(.error(response)))
        } else {
            guard let stringMetaData = metadata.jsonString else { return }
            var textMessage = textMessage
            textMessage.metadata = stringMetaData
            send(textMessage)
        }
    }

    func mentions(_ request: MentionRequest) {
        chat.prepareToSendAsync(req: request, type: .getHistory)
        cache?.message?.getMentions(threadId: request.threadId, offset: request.offset, count: request.count) { [weak self] messages, _ in
            let messages = messages.map { $0.codable() }
            let hasNext = messages.count >= request.count
            let response = ChatResponse(uniqueId: request.uniqueId, result: messages, hasNext: hasNext)
            self?.delegate?.chatEvent(event: .message(.messages(response)))
        }
    }

    func deliver(_ request: MessageDeliverRequest) {
        chat.prepareToSendAsync(req: request, type: .delivery)
    }

    func seen(_ request: MessageSeenRequest) {
        chat.prepareToSendAsync(req: request, type: .seen)
        cache?.message?.seen(threadId: request.threadId, messageId: request.messageId, mineUserId: chat.userInfo?.id ?? -1)
        cache?.conversation?.setUnreadCount(action: .decrease, threadId: request.threadId) { [weak self] unreadCount in
            self?.delegate?.chatEvent(event: .thread(.updatedUnreadCount(.init(result: .init(unreadCount: unreadCount, threadId: request.threadId)))))
        }
    }

    func onNewMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .message(.new(response)))
        delegate?.chatEvent(event: .thread(.activity(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        guard let message = response.result else { return }
        if message.threadId == nil {
            message.threadId = response.subjectId ?? message.conversation?.id
        }
        /// If we were sender of the message therfore we have seen all the messages inside the thread.
        let isMe = message.participant?.id == chat.userInfo?.id
        let unreadCountAction: CacheUnreadCountAction = isMe ? .set(0) : .increase
        cache?.conversation?.setUnreadCount(action: unreadCountAction, threadId: response.subjectId ?? -1) { [weak self] unreadCount in
            let unreadCount = UnreadCount(unreadCount: unreadCount, threadId: response.subjectId)
            self?.delegate?.chatEvent(event: .thread(.updatedUnreadCount(.init(result: unreadCount))))
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
        delegate?.chatEvent(event: .message(.sent(response)))
        cache?.deleteQueues(uniqueIds: [response.uniqueId ?? ""])
    }

    func onDeliverMessage(_ asyncMessage: AsyncMessage) {
        guard let response = asyncMessage.messageResponse(state: .delivered) else { return }
        delegate?.chatEvent(event: .message(.delivered(response)))
        if let delivered = response.result {
            cache?.message?.partnerDeliver(threadId: delivered.threadId ?? -1, messageId: delivered.messageId ?? -1, messageTime: delivered.messageTime ?? 0)
        }
        cache?.deleteQueues(uniqueIds: [response.uniqueId ?? ""])
    }

    func onSeenMessage(_ asyncMessage: AsyncMessage) {
        guard let response = asyncMessage.messageResponse(state: .seen) else { return }
        if let seenResponse = response.result {
            delegate?.chatEvent(event: .message(.seen(response)))
            cache?.message?.partnerSeen(threadId: seenResponse.threadId ?? -1, messageId: seenResponse.messageId ?? -1, mineUserId: chat.userInfo?.id ?? -1)
        }
    }

    func onLastMessageEdited(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.lastMessageEdited(response)))
        delegate?.chatEvent(event: .thread(.activity(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        if let thread = response.result {
            try? cache?.conversation?.replaceLastMessage(thread)
        }
    }

    func onLastMessageDeleted(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.lastMessageDeleted(response)))
        delegate?.chatEvent(event: .thread(.activity(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        if let thread = response.result {
            let lastMessageVO = Message(threadId: thread.id, message: thread.lastMessage)
            try? cache?.conversation?.replaceLastMessage(.init(id: lastMessageVO.threadId, lastMessage: lastMessageVO.message, lastMessageVO: lastMessageVO))
        }
    }

    func deliveredToParricipants(_ request: MessageDeliveredUsersRequest) {
        chat.prepareToSendAsync(req: request, type: .messageDeliveredToParticipants)
    }

    func onMessageDeliveredToParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .message(.deliveredToParticipants(response)))
    }

    func seenByParticipants(_ request: MessageSeenByUsersRequest) {
        chat.prepareToSendAsync(req: request, type: .getMessageSeenParticipants)
    }

    func onMessageSeenByParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .message(.seenByParticipants(response)))
    }

    func pin(_ request: PinUnpinMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .pinMessage)
    }

    func unpin(_ request: PinUnpinMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .unpinMessage)
    }

    func onPinUnPinMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<PinMessage> = asyncMessage.toChatResponse()
        let pin = asyncMessage.chatMessage?.type == .pinMessage
        delegate?.chatEvent(event: .message(pin ? .pin(response) : .unpin(response)))
        cache?.message?.pin(asyncMessage.chatMessage?.type == .pinMessage, response.subjectId ?? -1, response.result?.id ?? -1)
        cache?.message?.addOrRemoveThreadPinMessages(asyncMessage.chatMessage?.type == .pinMessage, response.subjectId ?? -1, response.result?.id ?? -1)
    }

    func replyPrivately(_ request: ReplyPrivatelyRequest) {
        chat.prepareToSendAsync(req: request, type: .replyPrivately)
    }

    func replyPrivately(_ replyMessage: ReplyPrivatelyRequest, _ fileRequest: UploadFileRequest) {
        (chat.file as? ChatFileManager)?.upload(fileRequest, nil) { [weak self] fileResponse, fileMetaData, error in
            self?.sendReplyPrivatelyMessageOnUploadCompletion(replyMessage, fileRequest.uniqueId, fileResponse, fileMetaData, error)
        }
    }

    func replyPrivately(_ replyMessage: ReplyPrivatelyRequest, _ imageRequest: UploadImageRequest) {
        (chat.file as? ChatFileManager)?.upload(imageRequest, nil) { [weak self] imageResponse, fileMetaData, error in
            self?.sendReplyPrivatelyMessageOnUploadCompletion(replyMessage, imageRequest.uniqueId, imageResponse, fileMetaData, error)
        }
    }

    private func sendReplyPrivatelyMessageOnUploadCompletion(_ replyMessage: ReplyPrivatelyRequest, _ uniqueId: String, _: UploadFileResponse?, _ metadata: FileMetaData?, _ error: ChatError?) {
        if let error = error {
            let response = ChatResponse(uniqueId: uniqueId, result: Any?.none, error: error)
            chat.delegate?.chatEvent(event: .system(.error(response)))
        } else {
            guard let stringMetaData = metadata.jsonString else { return }
            var textMessage = replyMessage
            textMessage.metadata = stringMetaData
            replyPrivately(textMessage)
        }
    }
}
