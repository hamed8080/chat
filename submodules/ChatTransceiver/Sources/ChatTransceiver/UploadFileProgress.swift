//
// UploadFileProgress.swift
// Copyright (c) 2022 ChatTransceiver
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public struct UploadFileProgress {
    public let percent: Int64
    public let totalSize: Int64
    public let bytesSend: Int64
}
