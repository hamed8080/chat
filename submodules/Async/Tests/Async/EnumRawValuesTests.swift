//
// EnumRawValuesTests.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import XCTest
@testable import Async

final class EnumRawValuesTests: XCTestCase {
    func test_asyncState_withInteger_isCorrect() {
        XCTAssertTrue(AsyncSocketState(rawValue: "connecting") == .connecting)
        XCTAssertTrue(AsyncSocketState(rawValue: "connected") == .connected)
        XCTAssertTrue(AsyncSocketState(rawValue: "asyncReady") == .asyncReady)
        XCTAssertTrue(AsyncSocketState(rawValue: "closed") == .closed)
        XCTAssertTrue(AsyncSocketState(rawValue: "closed")?.id == .closed)
    }

    func test_asyncMessageType_withInteger_isCorrect() {
        XCTAssertTrue(AsyncMessageTypes(rawValue: 0) == .ping)
        XCTAssertTrue(AsyncMessageTypes(rawValue: 1) == .serverRegister)
        XCTAssertTrue(AsyncMessageTypes(rawValue: 2) == .deviceRegister)
        XCTAssertTrue(AsyncMessageTypes(rawValue: 3) == .message)
        XCTAssertTrue(AsyncMessageTypes(rawValue: 4) == .messageAckNeeded)
        XCTAssertTrue(AsyncMessageTypes(rawValue: 5) == .messageSenderAckNeeded)
        XCTAssertTrue(AsyncMessageTypes(rawValue: 6) == .ack)
        XCTAssertTrue(AsyncMessageTypes(rawValue: 7) == .getRegisteredPeers)
        XCTAssertTrue(AsyncMessageTypes(rawValue: -3) == .peerRemoved)
        XCTAssertTrue(AsyncMessageTypes(rawValue: -2) == .registerQueue)
        XCTAssertTrue(AsyncMessageTypes(rawValue: -1) == .notRegistered)
        XCTAssertTrue(AsyncMessageTypes(rawValue: -99) == .errorMessage)
        XCTAssertTrue(AsyncMessageTypes(rawValue: 3)?.id == .message)
    }

    func test_asyncErrorCodes_isCorrect() {
        XCTAssertTrue( AsyncErrorCodes(rawValue: 4000) == .errorPing)
        XCTAssertTrue( AsyncErrorCodes(rawValue: 4001) == .socketIsNotConnected)
        XCTAssertTrue( AsyncErrorCodes(rawValue: 4002) == .socketAddressShouldStartWithWSS)
        XCTAssertTrue( AsyncErrorCodes(rawValue: 4002)?.id == .socketAddressShouldStartWithWSS)
    }
}
