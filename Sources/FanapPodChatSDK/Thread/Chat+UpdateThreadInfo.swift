//
// Chat+UpdateThreadInfo.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestUpdateThreadInfo(_ req: UpdateThreadInfoRequest, _ uploadProgress: @escaping UploadFileProgressType, _ completion: @escaping CompletionType<Conversation>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        uniqueIdResult?(req.uniqueId)
        if let image = req.threadImage {
            saveToCashe(req: req)
            uploadImage(req: image, uploadProgress: uploadProgress) { [weak self] _, fileMetaData, error in
                // send update thread Info with new file
                if let error = error {
                    completion(ChatResponse(uniqueId: req.uniqueId, result: nil, error: error))
                } else {
                    self?.updateThreadInfo(req, fileMetaData, completion)
                }
            }
        } else {
            // update directly without metadata
            updateThreadInfo(req, nil, completion)
        }
    }

    func updateThreadInfo(_ req: UpdateThreadInfoRequest, _ fileMetaData: FileMetaData? = nil, _ completion: @escaping CompletionType<Conversation>) {
        if let fileMetaData = fileMetaData {
            req.metadata = fileMetaData.convertCodableToString()
        }
        prepareToSendAsync(req: req, completion: completion)
    }

    func saveToCashe(req: UpdateThreadInfoRequest) {
        if let imageRequest = req.threadImage, config.enableCache == true {
            cache.write(cacheType: .sendFileMessageQueue(imageRequest, nil))
        }
    }
}

// Response
extension Chat {
    func onUpdateThreadInfo(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let conversation = try? JSONDecoder().decode(Conversation.self, from: data) else { return }
        delegate?.chatEvent(event: .thread(.threadInfoUpdated(conversation)))
        cache.write(cacheType: .threads([conversation]))
        cache.save()
        guard let callback: CompletionType<Conversation> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: conversation))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .threadInfoUpdated)
    }
}
