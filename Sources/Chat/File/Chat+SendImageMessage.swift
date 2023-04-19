//
// Chat+SendImageMessage.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatCore
import ChatDTO
import Foundation

extension Chat {
    func requestSendImageTextMessage(_ textMessage: SendTextMessageRequest,
                                     _ req: UploadImageRequest,
                                     _ onSent: OnSentType? = nil,
                                     _ onSeen: OnSeenType? = nil,
                                     _ onDeliver: OnDeliveryType? = nil,
                                     _ uploadProgress: UploadFileProgressType? = nil,
                                     _ uploadUniqueIdResult: UniqueIdResultType? = nil,
                                     _ messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        textMessage.uniqueId = req.uniqueId
        textMessage.typeCode = config.typeCode
        cache?.fileQueue.insert(req: textMessage, imageRequest: req)
        messageUniqueIdResult?(textMessage.uniqueId)
        uploadImage(req, uploadUniqueIdResult: uploadUniqueIdResult, uploadProgress: uploadProgress) { [weak self] _, fileMetaData, error in
            // completed upload file
            if let error = error {
                self?.delegate?.chatError(error: error)
            } else {
                guard let stringMetaData = fileMetaData.jsonString else { return }
                textMessage.metadata = stringMetaData
                self?.sendTextMessage(textMessage, uniqueIdResult: messageUniqueIdResult, onSent: onSent, onSeen: onSeen, onDeliver: onDeliver)
            }
        }
    }
}
