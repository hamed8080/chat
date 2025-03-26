//
// NewAsync.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Additive
import Foundation
import Logger

@AsyncGlobalActor
public protocol AsyncProtocol {
    var delegate: AsyncDelegate? { get }
    init(socket: WebSocketProvider, config: AsyncConfig, delegate: AsyncDelegate?, logger: Logger) async 
    func recreate()
    func connect()
    func send(message: SendAsyncMessageVO, type: AsyncMessageTypes)
    func reconnect()
}

protocol AsyncInternalProtocol: AsyncProtocol {
    var socket: WebSocketProvider { get }    
    var logger: Logger { get }
    var config: AsyncConfig { get }
    var stateModel: AsyncStateModel { get set }
    var deviceInfo: DeviceInfo? { get set }

    func sendInternalData(type: AsyncMessageTypes, data: Data?)
    func disposeObject()
    func sendPing()
    func onStatusChanged(_ status: AsyncSocketState, _ error: Error?)
}
