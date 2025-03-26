//
// GlobalVariables.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatModels
import ChatCore
import ChatDTO

public struct UploadResult: Sendable {
    public var resp: UploadFileResponse?
    public var metaData: FileMetaData?
    public var error: ChatError?
    
    public init(resp: UploadFileResponse?, metaData: FileMetaData?, error: ChatError?) {
        self.resp = resp
        self.metaData = metaData
        self.error = error
    }
    
    public init(_ resp: UploadFileResponse?, _ metaData: FileMetaData?, _ error: ChatError?) {
        self.resp = resp
        self.metaData = metaData
        self.error = error
    }
}

public typealias UploadCompletionType = @Sendable (UploadResult) -> Void
