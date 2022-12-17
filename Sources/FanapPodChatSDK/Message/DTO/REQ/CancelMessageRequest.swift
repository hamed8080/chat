//
// CancelMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public class CancelMessageRequest {
    public let textMessageUniqueId: String?
    public let editMessageUniqueId: String?
    public let forwardMessageUniqueId: String?
    public let fileMessageUniqueId: String?
    public let uploadImageUniqueId: String?
    public let uploadFileUniqueId: String?

    public init(textMessageUniqueId: String? = nil,
                editMessageUniqueId: String? = nil,
                forwardMessageUniqueId: String? = nil,
                fileMessageUniqueId: String? = nil,
                uploadImageUniqueId: String? = nil,
                uploadFileUniqueId: String? = nil)
    {
        self.textMessageUniqueId = textMessageUniqueId
        self.editMessageUniqueId = editMessageUniqueId
        self.forwardMessageUniqueId = forwardMessageUniqueId
        self.fileMessageUniqueId = fileMessageUniqueId
        self.uploadImageUniqueId = uploadImageUniqueId
        self.uploadFileUniqueId = uploadFileUniqueId
    }
}
