//
// EncodableExtensions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
extension Encodable {
    public func convertCodableToString() -> String? {
        if let data = try? JSONEncoder().encode(self) {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }

    func getParameterData() -> Data? {
        var parameterString = ""
        if let parameters = try? asDictionary(), parameters.count > 0 {
            parameters.forEach { key, value in
                let isFirst = parameters.first?.key == key
                parameterString.append("\(isFirst ? "" : "&")\(key)=\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
            }
            return parameterString.data(using: .utf8)
        }
        return nil
    }

    func toData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
