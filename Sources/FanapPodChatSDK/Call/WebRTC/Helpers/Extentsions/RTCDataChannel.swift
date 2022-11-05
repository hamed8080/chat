//
// RTCDataChannel.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import WebRTC
extension RTCDataChannel {
    func sendData(_ data: Data, isBinary: Bool = true) {
        if readyState == .open {
            let buffer = RTCDataBuffer(data: data, isBinary: isBinary)
            sendData(buffer)
        }
    }
}
