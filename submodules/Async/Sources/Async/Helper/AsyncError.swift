//
// AsyncError.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum AsyncErrorCodes: Int, Identifiable, CaseIterable {
    public var id: Self { self }
    case errorPing = 4000
    case socketIsNotConnected = 4001
    case socketAddressShouldStartWithWSS = 4002
    case undefined
}

/// When an error happen in the server or in your request you will receive an error this type.
public struct AsyncError: Error {
    /// Error code. it can be undifined.
    public var code: AsyncErrorCodes = .undefined

    /// The message that will give you more information about the error.
    public var message: String?

    /// The user info of the error.
    public var userInfo: [String: Any]?

    /// Raw error so you could diagnose the error in a way you prefer.
    public var rawError: Error?

    /// Initializer of an error.
    /// - Parameters:
    ///   - code: Error code. it can be undifined.
    ///   - message: The message that will give you more information about the error.
    ///   - userInfo: The user info of the error.
    ///   - rawError: Raw error so you could diagnose the error in a way you prefer.
    public init(code: AsyncErrorCodes = .undefined, message: String? = nil, userInfo: [String: Any]? = nil, rawError: Error? = nil) {
        self.code = code
        self.message = message
        self.userInfo = userInfo
        self.rawError = rawError
    }
}
