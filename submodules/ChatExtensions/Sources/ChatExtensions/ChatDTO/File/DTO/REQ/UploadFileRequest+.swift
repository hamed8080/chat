//
// UploadFileRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatCore
import ChatDTO
import Foundation

public extension UploadFileRequest {

    init(request: UploadFileRequest, userGroupHash: String?) {
        self = request
        self.userGroupHash = userGroupHash
    }
}
