//
// SendFileMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

class SendFileMessageRequest {
    class func handle(_ textMessage: SendTextMessageRequest,
                      _ req: UploadFileRequest,
                      _ onSent: OnSentType? = nil,
                      _ onSeen: OnSeenType? = nil,
                      _ onDeliver: OnDeliveryType? = nil,
                      _ uploadProgress: UploadFileProgressType? = nil,
                      _ uploadUniqueIdResult: UniqueIdResultType? = nil,
                      _ messageUniqueIdResult: UniqueIdResultType? = nil,
                      _ chat: Chat)
    {
        CacheFactory.write(cacheType: .sendFileMessageQueue(req, textMessage))
        PSM.shared.save()

        messageUniqueIdResult?(textMessage.uniqueId)
        chat.uploadFile(req: req, uploadUniqueIdResult: uploadUniqueIdResult, uploadProgress: uploadProgress) { _, fileMetaData, error in
            // completed upload file
            if let error = error {
                chat.delegate?.chatError(error: error)
            } else {
                guard let stringMetaData = fileMetaData.convertCodableToString() else { return }
                textMessage.metadata = stringMetaData
                Chat.sharedInstance.sendTextMessage(textMessage, uniqueIdresult: messageUniqueIdResult, onSent: onSent, onSeen: onSeen, onDeliver: onDeliver)
            }
        }
    }
}
