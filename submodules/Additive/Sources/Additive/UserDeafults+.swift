//
// UserDefaults+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public extension UserDefaults {
    func setValue(codable: Codable, forKey: String) {
        if let data = try? JSONEncoder.instance.encode(codable) {
            setValue(data, forKey: forKey)
        }
    }

    func codableValue<T: Codable>(forKey: String) -> T? {
        if let data = value(forKey: forKey) as? Data, let codable = try? JSONDecoder.instance.decode(T.self, from: data) {
            return codable
        } else { return nil }
    }
}
