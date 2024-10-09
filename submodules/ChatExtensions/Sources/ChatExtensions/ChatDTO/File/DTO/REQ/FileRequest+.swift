//
// FileRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatDTO
import ChatCore

public extension FileRequest {

    init(request: FileRequest, forceToDownloadFromServer: Bool) {
        self = request
        self.forceToDownloadFromServer = forceToDownloadFromServer
    }
}
