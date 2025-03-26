//
// QueueOfFileMessages+.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

extension QueueOfFileMessages {
    public var request: (UploadFileRequest, SendTextMessageRequest) {
        let text = SendTextMessageRequest(threadId: threadId ?? -1,
                                          textMessage: textMessage ?? "",
                                          messageType: messageType ?? .unknown,
                                          metadata: metadata,
                                          repliedTo: repliedTo,
                                          systemMetadata: nil,
                                          uniqueId: uniqueId ?? UUID().uuidString)
        let file = UploadFileRequest(data: fileToSend ?? Data(),
                                     fileExtension: fileExtension,
                                     fileName: fileName,
                                     description: "",
                                     isPublic: isPublic,
                                     mimeType: mimeType,
                                     originalName: originalName,
                                     userGroupHash: userGroupHash,
                                     uniqueId: uniqueId ?? UUID().uuidString)
        return (file, text)
    }
}
