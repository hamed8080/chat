//
// CallHistoryValueTransformer.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels
import Additive

@objc(CallHistoryValueTransformer)
final class CallHistoryValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        CallHistoryClass.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let callHistory = value as? CallHistoryClass else { return nil }
        do {
            let data = try JSONEncoder.instance.encode(callHistory)
            return data
        } catch {
            assertionFailure("Failed to transform `CallHistoryClass` to `Data`")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        do {
            let callHistory = try JSONDecoder.instance.decode(CallHistoryClass.self, from: data as Data)
            return callHistory
        } catch {
            assertionFailure("Failed to transform `Data` to `CallHistoryClass`")
            return nil
        }
    }
}

extension CallHistoryValueTransformer {
    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: CallHistoryValueTransformer.self))

    /// Registers the value transformer with `ValueTransformer`.
    public static func register() {
        let transformer = CallHistoryValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
