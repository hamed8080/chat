//
// Chat+CreateThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestCreateThread(_ req: CreateThreadRequest, _ completion: @escaping CompletionType<Conversation>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    func requestCreateThreadWithMessage(_ req: CreateThreadWithMessage, _ completion: @escaping CompletionType<Conversation>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    func requestCreateThreadWithFileMessage(_ request: CreateThreadRequest,
                                            _ textMessage: SendTextMessageRequest,
                                            _ uploadFile: UploadFileRequest,
                                            _ uploadProgress: UploadFileProgressType? = nil,
                                            _ onSent: OnSentType? = nil,
                                            _ onSeen: OnSeenType? = nil,
                                            _ onDeliver: OnDeliveryType? = nil,
                                            _ createThreadCompletion: CompletionType<Conversation>? = nil,
                                            _ uploadUniqueIdResult: UniqueIdResultType? = nil,
                                            _ messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: request, uniqueIdResult: nil) { [weak self] (response: ChatResponse<Conversation>) in

            guard let thread = response.result, let id = thread.id else { return }
            createThreadCompletion?(ChatResponse(result: thread))
            textMessage.threadId = id
            uploadFile.userGroupHash = thread.userGroupHash
            self?.sendFileMessage(textMessage: textMessage,
                                  uploadFile: uploadFile,
                                  uploadProgress: uploadProgress,
                                  onSent: onSent,
                                  onSeen: onSeen,
                                  onDeliver: onDeliver,
                                  uploadUniqueIdResult: uploadUniqueIdResult,
                                  messageUniqueIdResult: messageUniqueIdResult)
        }
    }
}

// Response
extension Chat {
    func onCreateThread(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let newThread = try? JSONDecoder().decode(Conversation.self, from: data) else { return }
        delegate?.chatEvent(event: .thread(.threadNew(newThread)))
        cache.write(cacheType: .threads([newThread]))
        cache.save()
        guard let callback: CompletionType<Conversation> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: newThread))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .createThread)
    }
}
