//
// ForwardInfoValueTransformer.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels
import Additive

@objc(ForwardInfoValueTransformer)
final class ForwardInfoValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        ForwardInfoClass.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let forwardInfo = value as? ForwardInfoClass else { return nil }
        do {
            let data = try JSONEncoder.instance.encode(forwardInfo)
            return data
        } catch {
            assertionFailure("Failed to transform `ForwardInfo` to `Data`")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        do {
            let forwardInfo = try JSONDecoder.instance.decode(ForwardInfoClass.self, from: data as Data)
            return forwardInfo
        } catch {
            assertionFailure("Failed to transform `Data` to `ForwardInfo`")
            return nil
        }
    }
}

extension ForwardInfoValueTransformer {
    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: ForwardInfoValueTransformer.self))

    /// Registers the value transformer with `ValueTransformer`.
    public static func register() {
        let transformer = ForwardInfoValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
