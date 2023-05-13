//
// ChatImplementation+SendImageMessage.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatCore
import ChatDTO
import Foundation

public extension ChatImplementation {
    func requestSendImageTextMessage(textMessage: SendTextMessageRequest,
                                     req: UploadImageRequest,
                                     onSent: OnSentType? = nil,
                                     onSeen: OnSeenType? = nil,
                                     onDeliver: OnDeliveryType? = nil,
                                     uploadProgress: UploadFileProgressType? = nil,
                                     uploadUniqueIdResult: UniqueIdResultType? = nil,
                                     messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        var textMessage = textMessage
        textMessage.uniqueId = req.chatUniqueId
        cache?.fileQueue.insertImage(req: textMessage.queueOfFileMessages(req))
        messageUniqueIdResult?(textMessage.chatUniqueId)
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
