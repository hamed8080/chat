//
// UploadImageRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatCore
import ChatDTO
import ChatModels

public extension UploadImageRequest {
    var queueOfFileMessages: QueueOfFileMessages {
        .init(req: nil, imageRequest: self)
    }
}
