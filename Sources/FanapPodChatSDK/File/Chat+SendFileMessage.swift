//
// Chat+SendFileMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

extension Chat {
    func requestSendFileTextMessage(_ textMessage: SendTextMessageRequest,
                                    _ req: UploadFileRequest,
                                    _ onSent: OnSentType? = nil,
                                    _ onSeen: OnSeenType? = nil,
                                    _ onDeliver: OnDeliveryType? = nil,
                                    _ uploadProgress: UploadFileProgressType? = nil,
                                    _ uploadUniqueIdResult: UniqueIdResultType? = nil,
                                    _ messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        cache.write(cacheType: .sendFileMessageQueue(req, textMessage))
        cache.save()
        messageUniqueIdResult?(textMessage.uniqueId)
        uploadFile(req: req, uploadUniqueIdResult: uploadUniqueIdResult, uploadProgress: uploadProgress) { [weak self] _, fileMetaData, error in
            // completed upload file
            if let error = error {
                self?.delegate?.chatError(error: error)
            } else {
                guard let stringMetaData = fileMetaData.convertCodableToString() else { return }
                textMessage.metadata = stringMetaData
                self?.sendTextMessage(textMessage, uniqueIdresult: messageUniqueIdResult, onSent: onSent, onSeen: onSeen, onDeliver: onDeliver)
            }
        }
    }
}
