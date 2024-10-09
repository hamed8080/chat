//
// URLRequest+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

public extension URLRequest {
    var method: HTTPMethod {
        get {
            if let httpMethod = httpMethod, let value = HTTPMethod(rawValue: httpMethod) {
                return value
            } else {
                return .get
            }
        }
        set {
            httpMethod = newValue.rawValue
        }
    }
}
