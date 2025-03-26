//
// Codable+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct Voidcodable: Codable {}

public extension JSONDecoder {
    static let instance = JSONDecoder()
}

public extension JSONEncoder {
    static let instance = JSONEncoder()
}

public extension Encodable {
    var jsonString: String? {
        if let data = try? JSONEncoder.instance.encode(self) {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder.instance.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "failed to make json object", code: -1, userInfo: nil)
        }
        return dictionary
    }
    
    func asSendableDictionary() throws -> [String: Sendable] {
        let data = try JSONEncoder.instance.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Sendable] else {
            throw NSError(domain: "failed to make json object", code: -1, userInfo: nil)
        }
        return dictionary
    }

    func asDictionaryNuallable() throws -> [String: Any?] {
        let data = try JSONEncoder.instance.encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any?] else {
            throw NSError(domain: "failed to make json object", code: -1, userInfo: nil)
        }
        return dictionary
    }

    var parameterData: Data? {
        var parameterString = ""
        if let parameters = try? asDictionaryNuallable(), parameters.count > 0 {
            parameters.forEach { key, value in
                let isFirst = parameters.first?.key == key
                parameterString.append("\(isFirst ? "" : "&")\(key)=\(value ?? "")".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")
            }
            return parameterString.data(using: .utf8)
        }
        return nil
    }

    var data: Data? {
        try? JSONEncoder.instance.encode(self)
    }

    /// Convert the encodable to the data.
    var dataPrettyPrint: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(self)
        return data
    }

    /// A string value of encodable.
    var string: String? {
        guard let data = data else {
            return nil
        }
        let string = String(data: data, encoding: .utf8)
        return string
    }
}

public protocol SafeDecodable: Decodable, CaseIterable, RawRepresentable where RawValue: Decodable, AllCases: BidirectionalCollection {}

public extension SafeDecodable {
    init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
