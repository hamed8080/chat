//
// WebRTCClientDelegate.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public protocol WebRTCClientDelegate: AnyObject {
    func didIceConnectionStateChanged(iceConnectionState: IceConnectionState)
    func didReceiveData(data: Data)
    func didReceiveMessage(message: String)
    func didConnectWebRTC()
    func didDisconnectWebRTC()
}
