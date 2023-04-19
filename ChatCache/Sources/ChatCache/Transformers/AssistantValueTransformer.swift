//
//  AssistantValueTransformer.swift
//
//
//  Created by hamed on 1/5/23.
//

import Foundation
import ChatModels

@objc(AssistantValueTransformer)
final class AssistantValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        Invitee.self
    }

    override class func allowsReverseTransformation() -> Bool {
        true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let invitee = value as? Invitee else { return nil }
        do {
            let data = try JSONEncoder.instance.encode(invitee)
            return data
        } catch {
            assertionFailure("Failed to transform `Invitee` to `Data`")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        do {
            let invitee = try JSONDecoder.instance.decode(Invitee.self, from: data as Data)
            return invitee
        } catch {
            assertionFailure("Failed to transform `Data` to `Invitee`")
            return nil
        }
    }
}

extension AssistantValueTransformer {
    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: AssistantValueTransformer.self))

    /// Registers the value transformer with `ValueTransformer`.
    public static func register() {
        let transformer = AssistantValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
