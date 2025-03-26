//
// DownloadFileProgress.swift
// Copyright (c) 2022 ChatTransceiver
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public struct DownloadFileProgress: Sendable {
    public var percent: Int64
    public var totalSize: Int64
    public var bytesRecivied: Int64
}
