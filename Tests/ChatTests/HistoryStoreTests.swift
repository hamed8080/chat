//
// HistoryStoreTests.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 9/27/22.

import XCTest
@testable import Chat
@testable import Logger

// input: Request {from: Int?, count: 20 }
// input: Request {to: Int?, count: 20 }
// input: Request {offset: Int?, count: 20 }
// store: [Id: [Meesages]]
// emit to delegete: delegate.history(messages)

final class HistoryStoreTests: XCTestCase {
    private var sut: HistoryStore!
    let delegate = MockChatDelegate()

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = HistoryStore(chat: MockChatInternalProtocol.shared(delegate: delegate))
    }

    func test_messageArrayIsEmpty_init() {
        XCTAssertTrue(sut.history.isEmpty, "Message Array should be empty when initialize")
    }
    
    func test_requestWithFromTime_sameRequst() {
        // Given
        let fromTime = UInt(Date().millisecondsSince1970)
        let (firstInitResp, _) = fillHistory(fromTime: fromTime)

        // When
        let exp = expectation(description: "We should receive 20 items where the first and last id are the same")
        let newReq = GetHistoryRequest(threadId: 1, count: 20, fromTime: fromTime)
        delegate.historyDelegate = { resp in
            if firstInitResp.result?.contains(where: { $0.id == resp.result?.first?.id}) == true {
                exp.fulfill()
            }
        }
        sut.doRequest(newReq)

        // Then
        wait(for: [exp], timeout: 0.5)
    }

    func test_requestWithToTime_sameRequst() {
        // Given
        let toTime = UInt(Date().millisecondsSince1970)
        let (firstInitResp, _) = fillHistory(toTime: toTime)

        // When
        let exp = expectation(description: "We should receive 20 items where the first and last id are the same")
        let newReq = GetHistoryRequest(threadId: 1, count: 20, toTime: toTime)
        delegate.historyDelegate = { resp in
            if firstInitResp.result?.contains(where: { $0.id == resp.result?.first?.id}) == true {
                exp.fulfill()
            }
        }
        sut.doRequest(newReq)

        // Then
        wait(for: [exp], timeout: 0.5)
    }

    func test_requestWithOffset_sameRequst() {
        // Given
        let (firstInitResp, _) = fillHistory()

        // When
        let exp = expectation(description: "We should receive 20 items where the first and last id are the same")
        let newReq = GetHistoryRequest(threadId: 1, count: 20, offset: 0)
        delegate.historyDelegate = { resp in
            if firstInitResp.result?.contains(where: { $0.id == resp.result?.first?.id}) == true {
                exp.fulfill()
            }
        }
        sut.doRequest(newReq)

        // Then
        wait(for: [exp], timeout: 0.5)
    }

    func test_requestWithFromTime_firstTime() {
        // Given
        let req = GetHistoryRequest(threadId: 1, fromTime: UInt(Date().millisecondsSince1970))
        sut.doRequest(req)

        // When
        let resp = makeResponse()
        sut.onHistory(resp)

        // Then
        XCTAssertFalse(sut.history.isEmpty, "Message Array should not be empty when request and response has a value")
    }

    func test_requestExist_delegateCalledWithStoreResponse() {
        // Given
        let fromTime = UInt(Date().millisecondsSince1970)
        let (_, req) = fillHistory(fromTime: fromTime)

        // When
        let exp = expectation(description: "Expected to call delegate if the same request called.")
        delegate.historyDelegate = { resp in
            if resp.result?.count ?? 0 > 0 {
                exp.fulfill()
            }
        }
        sut.doRequest(req)

        // Then
        wait(for: [exp], timeout: 0.5)
    }

    func test_messagesWithFromTime_shouldReturn() {
        // Given
        let fromTime = UInt(Date().millisecondsSince1970)
        let (firstResp, req) = fillHistory(fromTime: fromTime)

        // When
        let newReq = GetHistoryRequest(threadId: req.threadId, fromTime: fromTime.advanced(by: -1))
        let resp = sut.messagesWithFromTime(newReq)

        // Then
        XCTAssertEqual(resp?.count ?? 0, firstResp.result?.count ?? 0, "Number of messages for the same response should be equal to 20.")
        XCTAssertGreaterThan(resp?.count ?? 0, 0, "There should be some items in the array due to the same request.")
    }

    func test_messagesWithToTime_shouldReturn() {
        // Given
        let toTime = UInt(Date().millisecondsSince1970)
        let (firstResp, req) = fillHistory(toTime: toTime)

        // When
        let newReq = GetHistoryRequest(threadId: req.threadId, toTime: toTime)
        let resp = sut.messagesWithToTime(newReq)

        // Then
        XCTAssertEqual(resp?.count ?? 0, firstResp.result?.count ?? 0, "Number of messages for the same response should be equal to 20.")
        XCTAssertGreaterThan(resp?.count ?? 0, 0, "There should be some items in the array due to the same request.")
    }

    func test_messagesWithOffset_shouldReturn() {
        // Given
        let (firstResp, req) = fillHistory()

        // When
        let newReq = GetHistoryRequest(threadId: req.threadId, count: 20, offset: 0)
        let resp = sut.messagesWithOffset(newReq)

        // Then
        XCTAssertEqual(resp?.count ?? 0, firstResp.result?.count ?? 0, "Number of messages for the same response should be equal to 20 with offset requesting.")
        XCTAssertGreaterThan(resp?.count ?? 0, 0, "There should be some items in the array due to the same request with offset.")
    }

    func test_response_doesNotHaveOffset() {
        // Given
        let (_, req) = fillHistory()

        // When
        let newReq = GetHistoryRequest(threadId: req.threadId, count: 20, offset: 20)
        let resp = sut.messagesWithOffset(newReq)

        // Then
        XCTAssertEqual(resp?.count ?? 0, 0, "There should be some items in the array due to the same request with offset.")
    }

    func test_whenEmpty_hasOffsetIsFalse() {
        // When
        let req = GetHistoryRequest(threadId: 1, count: 20, offset: 0)
        let result = sut.hasOffset(req)

        // Then
        XCTAssertFalse(result, "hasOffset should return false when init for the first time!")
    }

    func test_whenNotEmpty_hasTimeWithOffsetIsTrue() {
        // Given
        _ = fillHistory()

        // When
        let req = GetHistoryRequest(threadId: 1, count: 20, offset: 0)
        let result = sut.hasOffset(req)

        // Then
        XCTAssertTrue(result, "hasOffset should return true if it contains the offset!")
    }

    func test_hasOffsetIsFalse_whenDoesNotOffset() {
        // Given
        _ = fillHistory()

        // When
        let req = GetHistoryRequest(threadId: 1, count: 20, offset: 20)
        let result = sut.hasOffset(req)

        // Then
        XCTAssertFalse(result, "If the offset is bigger than what's inside the history cache it should return false")
    }

    func test_historyIsEmpty_afterReconnect() {
        // Given
         _ = fillHistory()
        
        // When
        sut.invalidate()

        // Then
        XCTAssertEqual(sut.history.count, 0, "Number of items inside the history dictionary should be 0")
    }

    func test_addedMessages_sorted() {
        // Given
        let time = UInt(Date().millisecondsSince1970)
        let message1 = Message(id: 1, message: "Message 1", time: time.advanced(by: 1))
        let message2 = Message(id: 2, message: "Message 2", time: time)
        let message3 = Message(id: 3, message: "Message 3", time: time.advanced(by: -4))

        // When
        let resp: ChatResponse<[Message]> = .init(result:[message1, message2, message3], subjectId: 1, typeCode: "default")
        sut.onHistory(resp)
        let result = sut.history[1]!

        // Then
        let m1 = result[0]
        let m2 = result[1]
        let m3 = result[2]
        XCTAssertTrue(m1.time ?? 0 < m2.time ?? 0 && m2.time ?? 0 < m3.time ?? 0, "Messages are not being sorted after appned")
    }

    func test_hasNextIsTrue_whenIsEqualCount() {
        // Given
        let fromTime = UInt(Date().millisecondsSince1970)
        _ = fillHistory(fromTime: fromTime)

        // When
        let req = GetHistoryRequest(threadId: 1, count: 20, fromTime: fromTime.advanced(by: -1))
        let exp = expectation(description: "Expect to set hasNext to true when it has equal number of values as count")
        delegate.historyDelegate = { resp in
            if resp.result?.count == req.count {
                exp.fulfill()
            }
        }
        sut.doRequest(req)

        // Then
        wait(for: [exp], timeout: 0.5)
    }

    private func fillHistory(fromTime: UInt? = nil, toTime: UInt? = nil) -> (ChatResponse<[Message]>, GetHistoryRequest) {
        let count = 20
        let req = GetHistoryRequest(threadId: 1, count: count, fromTime: fromTime, toTime: toTime)
        sut.doRequest(req)
        let firstResp = makeResponse(count: count, time: req.fromTime)
        sut.onHistory(firstResp)
        return (firstResp, req)
    }

    private func makeResponse(count: Int = 20, threadId: Int = 1, time: UInt? = nil) -> ChatResponse<[Message]> {
        var messages: [Message] = []
        for index in 0..<count {
            var message = Message(threadId: threadId, id: index, message: "", time: index == 0 ? time : time?.advanced(by: 1))
            message.message = "Message \(index)"
            messages.append(message)
        }
        let resp = ChatResponse<[Message]>(result: messages, subjectId: threadId, typeCode: "default")
        return resp
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
