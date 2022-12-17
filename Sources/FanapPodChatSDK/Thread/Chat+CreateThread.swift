//
// Chat+CreateThread.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Create a thread.
    /// - Parameters:
    ///   - request: The request of create a thread.
    ///   - completion: Response to create thread which contains a ``Conversation`` that includes threadId and other properties.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func createThread(_ request: CreateThreadRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// Create thread with a message.
    /// - Parameters:
    ///   - request: The request with a message and threadId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - onSent: Call when message is snet.
    ///   - onDelivery:  Call when message deliverd but not seen yet.
    ///   - onSeen: Call when message is seen.
    ///   - completion: Response of request and created thread.
    func createThreadWithMessage(_ request: CreateThreadWithMessage,
                                 uniqueIdResult: UniqueIdResultType? = nil,
                                 onSent _: OnSentType? = nil,
                                 onDelivery _: OnDeliveryType? = nil,
                                 onSeen _: OnSentType? = nil,
                                 completion: @escaping CompletionType<Conversation>)
    {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }

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
                                     uploadProgress: UploadFileProgressType? = nil,
                                     onSent: OnSentType? = nil,
                                     onSeen: OnSeenType? = nil,
                                     onDeliver: OnDeliveryType? = nil,
                                     createThreadCompletion: CompletionType<Conversation>? = nil,
                                     uploadUniqueIdResult: UniqueIdResultType? = nil,
                                     messageUniqueIdResult: UniqueIdResultType? = nil)
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
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadNew(response)))
        if let newThread = response.result {
            cache.write(cacheType: .threads([newThread]))
            cache.save()
        }
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
