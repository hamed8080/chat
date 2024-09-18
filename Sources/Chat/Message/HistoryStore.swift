//
// HistoryStore.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatModels
import ChatDTO
import Foundation
import ChatCore
import Additive
import ChatExtensions

final class HistoryStore {
    var chat: ChatInternalProtocol
    private var debug = ProcessInfo().environment["talk.pod.ir.chat.debugStore.debug"] == "1"

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func doRequest(_ request: GetHistoryRequest) {
        if chat.config.enableCache {
            requestFromCache(request)
        } else {
            directRequest(request)
        }
    }

    private func requestFromCache(_ request: GetHistoryRequest) {
        chat.cache?.message?.fetch(request.fetchRequest) { [weak self] messages, totalCacheCount in
            let messages = messages.map { $0.codable(fillConversation: false) }
            self?.onCacheResponse(request, messages, totalCacheCount)
        }
    }

    private func onCacheResponse(_ req: GetHistoryRequest, _ messages: [Message], _ totalCacheCount: Int) {
        if !messages.isEmpty {
            emit(makeResponse(req, messages: messages))
        } else {
            directRequest(req)
        }
    }

    private func directRequest(_ req: GetHistoryRequest) {
        log("request directly to the chat server")
        chat.prepareToSendAsync(req: req, type: .getHistory)
    }

    private func makeResponse(_ req: GetHistoryRequest, messages: [Message]) -> ChatResponse<[Message]> {
        let resp = ChatResponse<[Message]>(uniqueId: req.uniqueId,
                                           result: messages,
                                           hasNext: messages.count >= req.count,
                                           cache: false,
                                           subjectId: req.threadId,
                                           typeCode: req.toTypeCode(chat))
        return resp
    }

    func onHistory(_ response: ChatResponse<[Message]>) {
        chat.delegate?.chatEvent(event: .message(.history(response)))
    }

    private func emit(_ response: ChatResponse<[Message]>) {
        chat.delegate?.chatEvent(event: .message(.history(response)))
    }

    func invalidate() {
        chat.cache?.message?.truncate()
    }

    private func log(_ message: String) {
#if DEBUG
        if debug {
            chat.logger.log(title: "HistoryStore", message: message, persist: false, type: .internalLog, userInfo: [:])
        }
#endif
    }
}
