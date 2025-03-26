//
// ReplyInfoValueTransformer.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels
import Additive

@objc(ReplyInfoValueTransformer)
final class ReplyInfoValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        ReplyInfoClass.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let replyInfo = value as? ReplyInfoClass else { return nil }
        do {
            let data = try JSONEncoder.instance.encode(replyInfo)
            return data
        } catch {
            assertionFailure("Failed to transform `ReplyInfo` to `Data`")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        do {
            let replyInfo = try JSONDecoder.instance.decode(ReplyInfoClass.self, from: data as Data)
            return replyInfo
        } catch {
            assertionFailure("Failed to transform `Data` to `ReplyInfo`")
            return nil
        }
    }
}

extension ReplyInfoValueTransformer {
    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: ReplyInfoValueTransformer.self))

    /// Registers the value transformer with `ValueTransformer`.
    public static func register() {
        let transformer = ReplyInfoValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
