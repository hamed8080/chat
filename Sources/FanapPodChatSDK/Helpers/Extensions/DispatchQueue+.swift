//
// DispatchQueue+.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

extension DispatchQueue: DispatchQueueProtocol {
    public func async(execute work: @escaping @convention(block) () -> Void) {
        async(group: nil, qos: .unspecified, flags: [], execute: work)
    }
}

public protocol DispatchQueueProtocol {
    func async(execute work: @escaping @convention(block) () -> Void)
}
