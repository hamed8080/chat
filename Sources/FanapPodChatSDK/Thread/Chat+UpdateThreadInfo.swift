//
// Chat+UpdateThreadInfo.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    /// Update details of a thread.
    /// - Parameters:
    ///   - request: The request might contain an image, title, description, and a threadId.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - uploadProgress: Upload progrees if you update image of the thread.
    ///   - completion: Response of update.
    public func updateThreadInfo(_ request: UpdateThreadInfoRequest, uniqueIdResult _: UniqueIdResultType? = nil, uploadProgress: @escaping UploadFileProgressType, completion: @escaping CompletionType<Conversation>) {
        if let image = request.threadImage {
            uploadImage(image, uploadProgress: uploadProgress) { [weak self] _, fileMetaData, error in
                // send update thread Info with new file
                if let error = error {
                    completion(ChatResponse(uniqueId: request.uniqueId, result: nil, error: error))
                } else {
                    self?.updateThreadInfo(request, fileMetaData, completion)
                }
            }
        } else {
            // update directly without metadata
            updateThreadInfo(request, nil, completion)
        }
    }

    func updateThreadInfo(_ req: UpdateThreadInfoRequest, _ fileMetaData: FileMetaData? = nil, _ completion: @escaping CompletionType<Conversation>) {
        if let fileMetaData = fileMetaData {
            req.metadata = fileMetaData.convertCodableToString()
        }
        prepareToSendAsync(req: req, completion: completion)
    }
}

// Response
extension Chat {
    func onUpdateThreadInfo(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadInfoUpdated(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
