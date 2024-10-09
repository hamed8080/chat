//
// PinMessageValueTransformer.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels
import Additive

@objc(PinMessageValueTransformer)
final class PinMessageValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        PinMessageClass.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let pinMessage = value as? PinMessageClass else { return nil }
        do {
            let data = try JSONEncoder.instance.encode(pinMessage)
            return data
        } catch {
            assertionFailure("Failed to transform `pinMessage` to `Data`")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        do {
            let pinMessage = try JSONDecoder.instance.decode(PinMessageClass.self, from: data as Data)
            return pinMessage
        } catch {
            assertionFailure("Failed to transform `Data` to `PinMessage`")
            return nil
        }
    }
}

extension PinMessageValueTransformer {
    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: PinMessageValueTransformer.self))

    /// Registers the value transformer with `ValueTransformer`.
    public static func register() {
        let transformer = PinMessageValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
