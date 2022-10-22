//
// CancelMessageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class CancelMessageRequestHandler {
    class func handle(_ chat: Chat, _ request: CancelMessageRequest, _ completion: @escaping CompletionType<Bool>) {
        if chat.config?.enableCache == true {
            if let uniqueId = request.textMessageUniqueId {
                CacheFactory.write(cacheType: .deleteWaitTextMessage(uniqueId))
                completion(true, uniqueId, nil)
            } else if let uniqueId = request.editMessageUniqueId {
                CacheFactory.write(cacheType: .deleteEditTextMessage(uniqueId))
                completion(true, uniqueId, nil)
            } else if let uniqueId = request.forwardMessageUniqueId {
                CacheFactory.write(cacheType: .deleteForwardMessage(uniqueId))
                completion(true, uniqueId, nil)
            } else if let uniqueId = request.fileMessageUniqueId {
                CacheFactory.write(cacheType: .deleteWaitFileMessage(uniqueId))
                completion(true, uniqueId, nil)
            } else if let uniqueId = request.uploadFileUniqueId {
                chat.manageUpload(uniqueId: uniqueId, action: .cancel, isImage: false) { _, state in
                    completion(state, uniqueId, nil)
                }
            } else if let uniqueId = request.uploadImageUniqueId {
                chat.manageUpload(uniqueId: uniqueId, action: .cancel, isImage: true) { _, state in
                    completion(state, uniqueId, nil)
                }
            }
        }
    }
}
