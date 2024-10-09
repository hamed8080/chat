//
// RTCDataChannel+.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

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
