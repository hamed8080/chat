//
// DownloaUploadActions.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public enum DownloaUploadAction: Identifiable, CaseIterable, Sendable {
    public var id: Self { self }
    case cancel
    case suspend
    case resume
}
