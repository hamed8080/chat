//
// Chat+SendFileMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public extension Chat {
    /// Send a file message.
    /// - Parameters:
    ///   - textMessage: A text message with a threadId.
    ///   - uploadFile: The progress of uploading file.
    ///   - uploadProgress: The progress of uploading file.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func sendFileMessage(textMessage: SendTextMessageRequest,
                         uploadFile: UploadFileRequest,
                         uploadProgress: UploadFileProgressType? = nil,
                         onSent: OnSentType? = nil,
                         onSeen: OnSeenType? = nil,
                         onDeliver: OnDeliveryType? = nil,
                         uploadUniqueIdResult: UniqueIdResultType? = nil,
                         messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        if let uploadRequest = uploadFile as? UploadImageRequest {
            requestSendImageTextMessage(textMessage, uploadRequest, onSent, onSeen, onDeliver, uploadProgress, uploadUniqueIdResult, messageUniqueIdResult)
            return
        }
        cache.write(cacheType: .sendFileMessageQueue(uploadFile, textMessage))
        cache.save()
        messageUniqueIdResult?(textMessage.uniqueId)
        self.uploadFile(uploadFile, uploadUniqueIdResult: uploadUniqueIdResult, uploadProgress: uploadProgress) { [weak self] _, fileMetaData, error in
            // completed upload file
            if let error = error {
                self?.delegate?.chatError(error: error)
            } else {
                guard let stringMetaData = fileMetaData.convertCodableToString() else { return }
                textMessage.metadata = stringMetaData
                self?.sendTextMessage(textMessage, uniqueIdResult: messageUniqueIdResult, onSent: onSent, onSeen: onSeen, onDeliver: onDeliver)
            }
        }
    }

    /// Reply to a mesaage inside a thread with a file.
    /// - Parameters:
    ///   - replyMessage: The request that contains the threadId and a text message an id of an message you want to reply.
    ///   - uploadFile: The request that contains the data of file and other file properties
    ///   - uploadProgress: The progress of uploading file.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - messageUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func replyFileMessage(replyMessage: ReplyMessageRequest,
                          uploadFile: UploadFileRequest,
                          uploadProgress: UploadFileProgressType? = nil,
                          onSent: OnSentType? = nil,
                          onSeen: OnSeenType? = nil,
                          onDeliver: OnDeliveryType? = nil,
                          uploadUniqueIdResult: UniqueIdResultType? = nil,
                          messageUniqueIdResult: UniqueIdResultType? = nil)
    {
        sendFileMessage(textMessage: replyMessage,
                        uploadFile: uploadFile,
                        uploadProgress: uploadProgress,
                        onSent: onSent,
                        onSeen: onSeen,
                        onDeliver: onDeliver,
                        uploadUniqueIdResult: uploadUniqueIdResult,
                        messageUniqueIdResult: messageUniqueIdResult)
    }
}
