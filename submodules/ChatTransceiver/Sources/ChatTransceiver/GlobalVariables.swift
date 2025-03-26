//
// GlobalVariables.swift
// Copyright (c) 2022 ChatTransceiver
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public typealias DownloadProgressType = @Sendable (DownloadFileProgress) -> Void
public typealias UploadProgressType = @Sendable (UploadFileProgress?) -> Void
public typealias ProgressCompletionType = @Sendable (Data?, HTTPURLResponse?, Error?) -> Void
