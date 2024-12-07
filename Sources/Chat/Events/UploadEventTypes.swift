//
// UploadEventTypes.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import ChatCore
import ChatModels
import ChatTransceiver
import Foundation

public enum UploadEventTypes: Sendable {
    case resumed(uniqueId: String)
    case canceled(uniqueId: String)
    case suspended(uniqueId: String)
    case progress(String, UploadFileProgress?)
    case completed(uniqueId: String, fileMetaData: FileMetaData?, data: Data?, error: Error?)
    case failed(uniqueId: String, error: ChatError?)
}
