//
// CallMessageProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import Foundation

/// For sending any call messages to ChatCall SDK.
@ChatGlobalActor
public protocol CallMessageProtocol: AnyObject {
    func onCallMessageDelegate(asyncMessage: AsyncMessage, chat: ChatImplementation)
}
