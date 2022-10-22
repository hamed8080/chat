//
// UpdateThreadInfoRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

public class UpdateThreadInfoRequestHandler {
    class func handle(_ chat: Chat,
                      _ req: UpdateThreadInfoRequest,
                      _ uploadProgress: @escaping UploadFileProgressType,
                      _ completion: @escaping CompletionType<Conversation>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        uniqueIdResult?(req.uniqueId)

        if let image = req.threadImage {
            saveToCashe(req: req)
            chat.uploadImage(req: image, uploadProgress: uploadProgress) { _, fileMetaData, error in
                // send update thread Info with new file
                if let error = error {
                    completion(nil, nil, error)
                } else {
                    updateThreadInfo(req, fileMetaData, completion)
                }
            }
        } else {
            // update directly without metadata
            updateThreadInfo(req, nil, completion)
        }
    }

    class func updateThreadInfo(_ req: UpdateThreadInfoRequest, _ fileMetaData: FileMetaData? = nil, _ completion: @escaping CompletionType<Conversation>) {
        if let fileMetaData = fileMetaData {
            req.metadata = fileMetaData.convertCodableToString()
        }
        Chat.sharedInstance.prepareToSendAsync(req: req,
                                               clientSpecificUniqueId: req.uniqueId,
                                               subjectId: req.threadId,
                                               messageType: .updateThreadInfo) { _ in

        } completion: { response in
            completion(response.result as? Conversation, response.uniqueId, response.error)
        }
    }

    private class func saveToCashe(req: UpdateThreadInfoRequest) {
        if let imageRequest = req.threadImage, Chat.sharedInstance.config?.enableCache == true {
            CacheFactory.write(cacheType: .uploadImageQueue(imageRequest))
        }
    }
}
