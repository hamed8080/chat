//
// Chat+LastSeenUpdate.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Event
extension Chat {
    func onLastSeenUpdate(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<LastSeenMessageResponse> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
    }
}

struct LastSeenMessageResponse: Decodable {
    let id: Int?
    var uniqueId: String?

    enum CodingKeys: CodingKey {
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        id = try container?.decodeIfPresent(Int.self, forKey: .id)
    }
}
