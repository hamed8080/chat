//
// DeleteTagRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class DeleteTagRequest: BaseRequest {
    public var id: Int

    public init(id: Int, uniqueId: String? = nil) {
        self.id = id
        super.init(uniqueId: uniqueId)
    }
}
