//
// AllThreads.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class AllThreads: BaseRequest {
    private let summary: Bool

    /// Init the request.
    /// - Parameters:
    ///   - summary: If it set to true the result only contains the ids of threads not other properties.
    ///   - uniqueId: The optional uniqueId.
    public init(summary: Bool = false, uniqueId: String? = nil) {
        self.summary = summary
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case summary
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(summary, forKey: .summary)
    }
}
