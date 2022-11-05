//
// CallClientErrorRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class CallClientErrorRequest: BaseRequest {
    let code: CallClientErrorType
    let callId: Int

    public init(callId: Int, code: CallClientErrorType, uniqueId: String? = nil) {
        self.callId = callId
        self.code = code
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case code
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code.rawValue, forKey: .code)
    }
}
