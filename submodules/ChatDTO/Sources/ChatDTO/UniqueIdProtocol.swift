//
// UniqueIdProtocol.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation

public protocol UniqueIdProtocol: Encodable {
    var uniqueId: String { get }
}
