//
// ReceivingMedia.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

struct ReceivingMedia: Codable {
    let id: String
    let chatId: Int
    let rcvList: [ReceiveItem]
    let uniqueId: String
}

struct ReceiveItem: Codable {
    let id: Int
    let chatId: Int
    let clientId: Int
    let mline: Int
    let topic: String
    let mediaType: ReceiveItemMediaType
    let isReceiving: Bool
    let version: Int
}

enum ReceiveItemMediaType: Int, Codable {
    case audio = 0
    case video = 1
    case screenShare = 2
}
