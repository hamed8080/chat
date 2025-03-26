//
// NSError+.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

extension NSError {
    var isInDomainError: Bool {
        let urlErrorCodes: [URLError.Code] = [.timedOut,
                                              .badURL,
                                              .cannotConnectToHost,
                                              .cannotFindHost,
                                              .networkConnectionLost,
                                              .dnsLookupFailed,
                                              .badServerResponse,
                                              .notConnectedToInternet,
                                              .resourceUnavailable]
        let isInDomainError = urlErrorCodes.contains(where: {$0.rawValue == code})
        return isInDomainError
    }
}
