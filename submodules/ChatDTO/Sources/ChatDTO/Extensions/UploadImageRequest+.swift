//
// UploadImageRequest+.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

extension UploadImageRequest {
    public func textMessageRequest(textMessage: SendTextMessageRequest) -> SendTextMessageRequest {
        SendTextMessageRequest(request: textMessage, uniqueId: uniqueId)
    }
}
