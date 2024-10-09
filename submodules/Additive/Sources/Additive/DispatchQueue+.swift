//
// DispatchQueue+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

extension DispatchQueue: DispatchQueueProtocol {
    public func asyncWork(execute work: @escaping @convention(block) () -> Void) {
        async(group: nil, qos: .unspecified, flags: [], execute: work)
    }
}

public protocol DispatchQueueProtocol {
    func asyncWork(execute work: @escaping @convention(block) () -> Void)
}
