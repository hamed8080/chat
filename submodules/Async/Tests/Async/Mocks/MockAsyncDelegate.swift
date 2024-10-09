//
// MockAsyncDelegate.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import Logger
@testable import Async

final class MockAsyncDelegate: AsyncDelegate {

    var asyncMessageResult: ((AsyncMessage) -> Void)?
    var asyncStateChangedResult: ((AsyncSocketState, AsyncError?) -> Void)?
    var asyncMessageSentResult: ((Data?, AsyncError?) -> Void)?
    var asyncErrorResult: ((AsyncError) -> Void)?
    var asyncOnLogResult: ((Log) -> Void)?

    func asyncMessage(asyncMessage: AsyncMessage) {
        asyncMessageResult?(asyncMessage)
    }

    func asyncStateChanged(asyncState: AsyncSocketState, error: AsyncError?) {
        asyncStateChangedResult?(asyncState, error)
    }

    func asyncMessageSent(message: Data?, error: AsyncError?) {
        asyncMessageSentResult?(message, error)
    }

    func asyncError(error: AsyncError) {
        asyncErrorResult?(error)
    }

    func onLog(log: Log) {
        asyncOnLogResult?(log)
    }
}
