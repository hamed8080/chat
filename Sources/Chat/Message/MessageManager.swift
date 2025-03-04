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
    var exportVM: ExportMessagesInternalProtocol?
    private let debug = ProcessInfo().environment["ENABLE_MASSAGE_MANAGER_LOGGING"] == "1"
    private var fileManager: ChatFileManager? { chat.file as? ChatFileManager }

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
        emitEvent(.message(.cleared(response)))
    }

    func delete(_ request: DeleteMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .deleteMessage)
    }

    func delete(_ request: BatchDeleteMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .deleteMessage)
    }

    func onDeleteMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        emitEvent(.message(.deleted(response)))
        guard let tuple = response.deleteTuple(chat.userInfo?.id) else { return }
        Task {
            await cache?.message?.deleteAndReduceUnreadCountIfNeeded(tuple.threadId, tuple.messageId, tuple.userId)
        }
    }

    func edit(_ request: EditMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .editMessage)
        cache?.editQueue?.insert(models: [request.queueOfTextMessages])
    }

    func onEditMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        emitEvent(.message(.edited(response)))
        cache?.deleteQueues(uniqueIds: [response.uniqueId ?? ""])
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
        chat.coordinator.history.doRequest(request)
    }

    func unsentTextMessages(_ request: GetHistoryRequest) {
        let typeCode = request.toTypeCode(chat)
        cache?.textQueue?.unsendForThread(request.threadId, request.count, request.nonNegativeOffset) { [weak self] unsedTexts, _ in
            self?.emitEvent(event: unsedTexts.toEvent(request, typeCode))
        }
    }

    func unsentEditMessages(_ request: GetHistoryRequest) {
        let typeCode = request.toTypeCode(chat)
        cache?.editQueue?.unsendForThread(request.threadId, request.count, request.nonNegativeOffset) { [weak self] unsendEdits, _ in
            self?.emitEvent(event: unsendEdits.toEvent(request, typeCode))
        }
    }

    func unsentForwardMessages(_ request: GetHistoryRequest) {
        let typeCode = request.toTypeCode(chat)
        cache?.forwardQueue?.unsendForThread(request.threadId, request.count, 100) { [weak self] unsendForwards, _ in
            self?.emitEvent(event: unsendForwards.toEvent(request, typeCode))
        }
    }

    func unsentFileMessages(_ request: GetHistoryRequest) {
        let typeCode = request.toTypeCode(chat)
        cache?.fileQueue?.unsendForThread(request.threadId, request.count, request.nonNegativeOffset) { [weak self] unsendFiles, _ in
            self?.emitEvent(event: unsendFiles.toEvent(request, typeCode))
        }
    }

    func getHashtagList(_ request: GetHistoryRequest) {
        history(request)
    }

    func onGetHistroy(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Message]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)        
        chat.coordinator.history.onHistory(response)
    }

    func send(_ request: ForwardMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .forwardMessage)
        cache?.forwardQueue?.insert(models: [request.queueOfForwardMessages])
    }

    func send(_ request: SendTextMessageRequest) {
        chat.prepareToSendAsync(req: request, type: .message)
        try? cache?.conversation?.replaceLastMessage(toConversation(request: request))
        cache?.textQueue?.insert(models: [request.queueOfTextMessages])
    }

    func send(_ request: LocationMessageRequest) {
        let mapStaticReq = MapStaticImageRequest(request: request)
        Task { @ChatGlobalActor [weak self] in
            guard let self = self else { return }
            do {
                guard let data = try await chat.map.image(mapStaticReq) else { return }
                let tuple = mapImageToRequest(data, request)
                let response = try await chat.map.reverse(tuple.reverseReq)
                if let reverse = response {
                    self.sendTextLoactionMessage(request.mapCenter, tuple.sendTextReq, tuple.uploadImageReq, reverse)
                }
            } catch {
                log("Failed to get map image or reverse the geolocation with error: \(error.localizedDescription)")
            }
        }
    }

    private func sendTextLoactionMessage(_ coordinate: Coordinate, _ textMessageReq: SendTextMessageRequest, _ imageRequest: UploadImageRequest, _ reverse: MapReverse) {
        cache?.fileQueue?.insert(models: [textMessageReq.queueOfFileMessages(imageRequest)])
        fileManager?.upload(imageRequest, nil) { [weak self] resp in
            self?.sendTextMessageOnUpload(textMessageReq, imageRequest.uniqueId, resp.toMapMetaData(coordinate))
        }
    }

    func reply(_ request: ReplyMessageRequest) {
        send(request.textMessageRequest)
    }

    func send(_ textMessage: SendTextMessageRequest, _ imageRequest: UploadImageRequest) {
        let textMessage = imageRequest.textMessageRequest(textMessage: textMessage)
        cache?.fileQueue?.insert(models: [textMessage.queueOfFileMessages(imageRequest)])
        fileManager?.upload(imageRequest, nil) { [weak self] resp in
            self?.sendTextMessageOnUpload(textMessage, imageRequest.uniqueId, resp)
        }
    }

    func send(_ textMessage: SendTextMessageRequest, _ fileRequest: UploadFileRequest) {
        let textMessage = fileRequest.textMessageRequest(textMessage: textMessage)
        cache?.fileQueue?.insert(models: [textMessage.queueOfFileMessages(fileRequest)])
        fileManager?.upload(fileRequest, nil) { [weak self] resp in
            self?.sendTextMessageOnUpload(textMessage, fileRequest.uniqueId, resp)
        }
    }

    func reply(_ replyMessage: ReplyMessageRequest, _ fileRequest: UploadFileRequest) {
        send(replyMessage.textMessageRequest, fileRequest)
    }

    func reply(_ replyMessage: ReplyMessageRequest, _ imageRequest: UploadImageRequest) {
        send(replyMessage.textMessageRequest, imageRequest)
    }
    
    private nonisolated func sendTextMessageOnUpload(_ textMessage: SendTextMessageRequest, _ uniqueId: String, _ resp: UploadResult) {
        Task { @ChatGlobalActor [weak self] in
            guard let self = self else { return }
            self.sendTextMessageOnUploadCompletion(textMessage, uniqueId, resp)
        }
    }

    private func sendTextMessageOnUploadCompletion(_ textMessage: SendTextMessageRequest, _ uniqueId: String, _ resp: UploadResult) {
        let typeCode = textMessage.toTypeCode(chat)
        if let error = resp.error {
            let response = ChatResponse<Sendable>(uniqueId: uniqueId, error: error, typeCode: typeCode)
            emitEvent(.system(.error(response)))
        } else {
            guard let stringMetaData = resp.metaData.jsonString else { return }
            var textMessage = textMessage
            textMessage.metadata = stringMetaData
            send(textMessage)
        }
    }

    func mentions(_ request: MentionRequest) {
        chat.prepareToSendAsync(req: request, type: .getHistory)
        let typeCode = request.toTypeCode(chat)
        cache?.message?.getMentions(threadId: request.threadId, offset: request.offset, count: request.count) { [weak self] messages, _ in
            self?.emitEvent(event: messages.toMentionEvent(request, typeCode))
        }
    }

    func deliver(_ request: MessageDeliverRequest) {
        chat.prepareToSendAsync(req: request, type: .delivery)
    }

    func seen(_ request: MessageSeenRequest) {
        chat.prepareToSendAsync(req: request, type: .seen)
        cache?.message?.seen(threadId: request.threadId, messageId: request.messageId, mineUserId: chat.userInfo?.id ?? -1)
        Task {
            await cache?.conversation?.setUnreadCount(action: .decrease, threadId: request.threadId)
        }
    }

    func onNewMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        let copiedMessage = response.result
        emitEvent(.message(.new(response)))
        guard let tuple = response.onNewMesageTuple(myId: chat.userInfo?.id) else { return }
        Task {
            await cache?.conversation?.setUnreadCount(action: tuple.unreadAction, threadId: response.subjectId ?? -1)
        }
        /// It will insert a new message into the Message table if the sender is not me
        /// and it will update a current message with a uniqueId of a message when we were the sender of a message, and consequently, it will set lastMessageVO for the thread.
        try? cache?.conversation?.replaceLastMessage(tuple.message.messageToConversation())
    }
    
    func onForwardMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        let copiedMessage = response.result
        emitEvent(.message(.forward(response)))
        guard let tuple = response.onNewMesageTuple(myId: chat.userInfo?.id) else { return }
        Task {
            await cache?.conversation?.setUnreadCount(action: tuple.unreadAction, threadId: response.subjectId ?? -1)
        }
        /// It will insert a new message into the Message table if the sender is not me
        /// and it will update a current message with a uniqueId of a message when we were the sender of a message, and consequently, it will set lastMessageVO for the thread.
        try? cache?.conversation?.replaceLastMessage(tuple.message.messageToConversation())
    }

    func onSentMessage(_ asyncMessage: AsyncMessage) {
        guard let response = asyncMessage.messageResponse(state: .sent) else { return }
        emitEvent(.message(.sent(response)))
        cache?.deleteQueues(uniqueIds: [response.uniqueId ?? ""])
    }

    func onDeliverMessage(_ asyncMessage: AsyncMessage) {
        guard let response = asyncMessage.messageResponse(state: .delivered) else { return }
        emitEvent(.message(.delivered(response)))
        if let delivered = response.result {
            cache?.message?.partnerDeliver(threadId: delivered.threadId ?? -1, messageId: delivered.messageId ?? -1, messageTime: delivered.messageTime ?? 0)
        }
        cache?.deleteQueues(uniqueIds: [response.uniqueId ?? ""])
    }

    func onSeenMessage(_ asyncMessage: AsyncMessage) {
        guard let response = asyncMessage.messageResponse(state: .seen) else { return }
        if let seenResponse = response.result {
            emitEvent(.message(.seen(response)))
            cache?.message?.partnerSeen(threadId: seenResponse.threadId ?? -1, messageId: seenResponse.messageId ?? -1, mineUserId: chat.userInfo?.id ?? -1)
        }
    }

    func onLastMessageEdited(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        let copied = response.result
        emitEvent(.thread(.lastMessageEdited(response)))
        if let thread = copied {
            try? cache?.conversation?.replaceLastMessage(thread)
        }
    }

    func onLastMessageDeleted(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        let copied = response.result
        emitEvent(.thread(.lastMessageDeleted(response)))
        if let thread = copied {
            try? cache?.conversation?.replaceLastMessage(lastMessageToConversation(thread: thread))
        }
    }

    func deliveredToParricipants(_ request: MessageDeliveredUsersRequest) {
        chat.prepareToSendAsync(req: request, type: .messageDeliveredToParticipants)
    }

    func onMessageDeliveredToParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse()
        emitEvent(.message(.deliveredToParticipants(response)))
    }

    func seenByParticipants(_ request: MessageSeenByUsersRequest) {
        chat.prepareToSendAsync(req: request, type: .getMessageSeenParticipants)
    }

    func onMessageSeenByParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse()
        emitEvent(.message(.seenByParticipants(response)))
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
        let threadId = response.subjectId ?? -1
        let messageId = response.result?.id ?? -1
        let copied = response.result
        chat.coordinator.conversation.onPinUnPin(pin, threadId, copied)
        emitEvent(.message(pin ? .pin(response) : .unpin(response)))
        cache?.message?.pin(pin, threadId, messageId)
        cache?.message?.addOrRemoveThreadPinMessages(pin, threadId, messageId)
    }

    func replyPrivately(_ request: ReplyPrivatelyRequest) {
        chat.prepareToSendAsync(req: request, type: .replyPrivately)
    }

    func replyPrivately(_ replyMessage: ReplyPrivatelyRequest, _ fileRequest: UploadFileRequest) {
        fileManager?.upload(fileRequest, nil) { [weak self] resp in
            self?.sendReplyPrivatelyMessageOnUploadCompletion(tuple: (resp, replyMessage, fileRequest.uniqueId))
        }
    }

    func replyPrivately(_ replyMessage: ReplyPrivatelyRequest, _ imageRequest: UploadImageRequest) {
        fileManager?.upload(imageRequest, nil) { [weak self] resp in
            self?.sendReplyPrivatelyMessageOnUploadCompletion(tuple: (resp, replyMessage, imageRequest.uniqueId))
        }
    }

    private nonisolated func sendReplyPrivatelyMessageOnUploadCompletion(tuple: ReplyPrivatelyResponse?) {
        Task { @ChatGlobalActor [weak self] in
            guard let self = self else { return }
            sendReplyPrivatelyMessageOnUpload(tuple: tuple)
        }
    }
    
    private func sendReplyPrivatelyMessageOnUpload(tuple: ReplyPrivatelyResponse?) {
        guard let tuple = tuple else { return }
        let typeCode = tuple.replyMessage.toTypeCode(chat)
        if let error = tuple.uploadedRes?.error {
            let response = ChatResponse<Sendable>(uniqueId: tuple.uniqueId, error: error, typeCode: typeCode)
            emitEvent(.system(.error(response)))
        } else {
            guard let stringMetaData = tuple.uploadedRes?.metaData.jsonString else { return }
            var textMessage = tuple.replyMessage
            textMessage.metadata = stringMetaData
            replyPrivately(textMessage)
        }
    }
    
    private nonisolated func emitEvent(event: ChatEventType) {
        Task { @ChatGlobalActor [weak self] in
            self?.emitEvent(event)
        }
    }
    
    private func emitEvent(_ event: ChatEventType) {
        self.delegate?.chatEvent(event: event)
    }
    
    private func log(_ message: String) {
#if DEBUG
        if debug {
            chat.logger.log(title: "Message Manager", message: message, persist: false, type: .internalLog)
        }
#endif
    }
}
